import 'dart:async';
import 'package:logize/apis/db.dart';
import 'package:logize/apis/membership.dart';
import 'package:logize/apis/notifications.dart';
import 'package:logize/event_processor.dart';
import 'package:logize/config/locales.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logize/widgets/crash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:logize/widgets/large_screen/side_navbar.dart';
import 'package:logize/widgets/navbar.dart';
import 'package:flutter/material.dart';

final sharedPrefs = SharedPreferencesAsync();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

initLogize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();

  await db.init();
  await notif.init();
  await eventProcessor.init();
  await themeModePool.init();

  await membershipApi.init();

  runApp(const Logize());
}

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      ErrorWidget.builder = (FlutterErrorDetails details) =>
          CrashScreen(details);
      FlutterError.onError = (FlutterErrorDetails details) =>
          CrashScreen.showError(details);

      await initLogize();
    },
    (error, stack) {
      FlutterErrorDetails details = FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'logize crash box',
      );
      CrashScreen.showError(details);
    },
  );
}

class Logize extends StatelessWidget {
  const Logize({super.key});
  @override
  Widget build(BuildContext context) {
    final screenIsLarge = MediaQuery.sizeOf(context).width > 500;

    FlutterLocalization.instance.init(
      mapLocales: [
        const MapLocale('en', Tr.en),
        const MapLocale('es', Tr.es),
      ],
      initLanguageCode: 'en',
    );

    FlutterLocalization.instance.onTranslatedLanguage = (_) =>
        themeModePool.emit();

    return Swimmer<ThemeMode>(
      pool: themeModePool,
      builder: (context, mode) {
        eventProcessor.listen();
        return MaterialApp(
          title: 'Logize',
          scaffoldMessengerKey: scaffoldMessengerKey,
          supportedLocales: FlutterLocalization.instance.supportedLocales,
          localizationsDelegates:
              FlutterLocalization.instance.localizationsDelegates,
          themeMode: mode,
          theme: detaTheme,
          darkTheme: detaDarkTheme,
          home: Scaffold(
            body: screenIsLarge
                ? Row(
                    children: [
                      SideNavbar(key: UniqueKey()),
                      Expanded(child: RootScreenSwitch(key: UniqueKey())),
                    ],
                  )
                : RootScreenSwitch(key: UniqueKey()),
            bottomNavigationBar: !screenIsLarge ? Navbar() : null,
          ),
        );
      },
    );
  }
}
