import 'package:flutter/material.dart';

class CrashBox extends StatelessWidget {
  final FlutterErrorDetails details;
  const CrashBox(this.details, {super.key});

  static showError(FlutterErrorDetails details) {
    runApp(CrashBox(details));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text(
              'Logize has crashed! please copy the error and send to developer',
            ),
            Text(details.exception.toString()),
            Text(details.stack.toString()),
          ],
        ),
      ),
    );
  }
}
