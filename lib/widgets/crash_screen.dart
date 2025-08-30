import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/apis/back.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:restart_app/restart_app.dart';

class CrashScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const CrashScreen(this.details, {super.key});

  static showError(FlutterErrorDetails details) {
    throw Exception(details.exception);
  }

  @override
  Widget build(BuildContext context) {
    String status = 'init';

    return MaterialApp(
      theme: detaDarkTheme,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
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
                if (status == 'reported')
                  Txt("The error was successfully reported")
                else if (status == 'loading')
                  CircularProgressIndicator()
                else
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          'report error',
                          filled: false,
                          onPressed: () async {
                            try {
                              setState(() => status = 'loading');
                              await backApi.reportError(
                                '${details.exception}',
                              );
                              setState(() => status = 'reported');
                            } catch (e) {
                              SystemNavigator.pop();
                            }
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
      ),
    );
  }
}
