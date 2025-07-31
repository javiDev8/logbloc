import 'package:logize/config/locales.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class HelpSettings extends StatelessWidget {
  const HelpSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Exp(),
            Button(
              Tr.tutorial.getString(context),
              onPressed: () {},
            ),
            Button(
              Tr.reportBug.getString(context),
              onPressed: () {},
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('${Tr.version.getString(context)} 1.0.0'),
            ),
          ],
        ),
      ],
    );
  }
}
