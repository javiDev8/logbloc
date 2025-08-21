import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logize/apis/db.dart';
import 'package:logize/config/notifications.dart';
import 'package:logize/event_processor.dart';
import 'package:logize/config/locales.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logize/utils/noticable_print.dart';
import 'package:logize/widgets/crash_box.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:logize/widgets/large_screen/side_navbar.dart';
import 'package:logize/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

final sharedPrefs = SharedPreferencesAsync();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

initLogize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await notifs.initialize(
    notifsSettings,
    onDidReceiveNotificationResponse: notifResponseCallback,
  );

  await themeModePool.init();
  await db.init();
  await eventProcessor.init();

  requestNotifPermission();

  runApp(const Logize());
}

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      ErrorWidget.builder = (FlutterErrorDetails details) {
        if (kDebugMode) {
          return originalErrorWidgetBuilder(details);
        }
        return CrashBox(details);
      };
      FlutterError.onError = (FlutterErrorDetails details) {
        if (!kDebugMode) {
          CrashBox.showError(details);
        }
        FlutterError.presentError(details);
      };

      await initLogize();
    },
    (error, stack) {
      if (!kDebugMode) {
        FlutterErrorDetails details = FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'My App',
        );
        CrashBox.showError(details);
      }
      debugPrintStack(stackTrace: stack, label: error.toString());
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
            appBar: PreferredSize(
              preferredSize: Size(100, 50),
              child: Button(
                'test notifs',
                onPressed: () async {
                  try {
                    await notifs.show(
                      0,
                      'title',
                      'body',
                      //null,
                      NotificationDetails(
                        android: AndroidNotificationDetails(
                          'logize',
                          'sa',
                        ),
                      ),
                      payload: 'payload',
                    );
                    nPrint('after await');
                  } catch (e) {
                    nPrint('EXCEPTIONP: $e');
                  }
                },
              ),
            ),
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
