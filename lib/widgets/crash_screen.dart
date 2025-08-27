import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/utils/noticable_print.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:restart_app/restart_app.dart';

class CrashScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const CrashScreen(this.details, {super.key});

  static showError(FlutterErrorDetails details) {
    nPrint('ERROR: $details');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: detaDarkTheme,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.alert, color: Colors.red, size: 30),
                  Txt('Oops!', w: 8, color: Colors.red, s: 30),
                ],
              ),
              Txt('something went wrong!', w: 7, s: 20),
              Row(
                children: [
                  Expanded(
                    child: Button(
                      'report error',
                      filled: false,
                      onPressed: () {
                        // TODO: send exception and stacktrace to backend api
                      },
                    ),
                  ),
                  Expanded(
                    child: Button(
                      'restart app',
                      onPressed: () => Restart.restartApp(),
                    ),
                  ),
                ],
              ),
              if (kDebugMode) ...[Txt('${details.exception}')],
            ],
          ),
        ),
      ),
    );
  }
}
