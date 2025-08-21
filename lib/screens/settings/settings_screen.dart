import 'package:logize/config/locales.dart';
import 'package:logize/config/notifications.dart';
//import 'package:logize/screens/settings/help_settings.dart';
import 'package:logize/screens/settings/preferences_settings.dart';
import 'package:logize/utils/noticable_print.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logize/widgets/design/topbar_wrap.dart';
import 'package:logize/widgets/design/txt.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wrapBar(
        backable: false,
        children: [Txt(Tr.settings.getString(context))],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 10),
        child: ListView(
          children: [
            SectionDivider(string: Tr.preferences.getString(context)),
            PreferencesSettings(),

            //SectionDivider(string: Tr.help.getString(context)),
            //HelpSettings(),
            Button(
              'test',
              onPressed: () async {
                await notif.requestNotifPermission();
                nPrint('permisson requested succesfully');
                await notif.test();
                nPrint('after notif schedule');
              },
            ),
          ],
        ),
      ),
    );
  }
}
