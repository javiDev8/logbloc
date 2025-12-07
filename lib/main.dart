import 'dart:async';
import 'package:logbloc/apis/db.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/apis/notifications.dart';
import 'package:logbloc/event_processor.dart';
import 'package:logbloc/config/locales.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logbloc/screens/welcome/welcome_screen.dart';
import 'package:logbloc/utils/app_review_manager.dart';
import 'package:logbloc/widgets/crash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/screens/root_screen_switch.dart';
import 'package:logbloc/widgets/navbar.dart';
import 'package:flutter/material.dart';

final sharedPrefs = SharedPreferencesAsync();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

initLogbloc() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();

  //await sharedPrefs.clear();

  await db.init();
  await notif.init();
  await eventProcessor.init();
  await themeModePool.init();
  await membershipApi.init();

  await modelsPool.retrieve();

  runApp(const Logbloc());
}

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      ErrorWidget.builder = (FlutterErrorDetails details) =>
          CrashScreen(details);
      FlutterError.onError = (FlutterErrorDetails details) =>
          CrashScreen.showError(details);

      await initLogbloc();
    },
    (error, stack) {
      FlutterErrorDetails details = FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'logbloc crash box',
      );
      CrashScreen.showError(details);
    },
  );
}

class Logbloc extends StatelessWidget {
  const Logbloc({super.key});
  @override
  Widget build(BuildContext context) {
    FlutterLocalization.instance.init(
      mapLocales: [const MapLocale('en', Tr.en), const MapLocale('es', Tr.es)],
      initLanguageCode: 'en',
    );

    FlutterLocalization.instance.onTranslatedLanguage = (_) =>
        themeModePool.emit();

    return Swimmer<ThemeMode>(
      pool: themeModePool,
      builder: (context, mode) {
        eventProcessor.listen();
        final app = MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Logbloc',
          scaffoldMessengerKey: scaffoldMessengerKey,
          supportedLocales: FlutterLocalization.instance.supportedLocales,
          localizationsDelegates:
              FlutterLocalization.instance.localizationsDelegates,
          themeMode: mode,
          theme: detaTheme,
          darkTheme: detaDarkTheme,
          home: membershipApi.welcomed
              ? Builder(
                  builder: (context) {
                    // Check for review after app starts
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      AppReviewManager.checkAndRequestReview(context);
                    });
                    return Scaffold(
                      body: RootScreenSwitch(key: UniqueKey()),
                      bottomNavigationBar: Navbar(),
                    );
                  },
                )
              : WelcomeScreen(),
        );

        // Check for review after app starts (for welcome screen case)
        if (!membershipApi.welcomed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = scaffoldMessengerKey.currentContext;
            if (context != null) {
              AppReviewManager.checkAndRequestReview(context);
            }
          });
        }

        return app;
      },
    );
  }
}
