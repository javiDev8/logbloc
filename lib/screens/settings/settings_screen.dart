import 'package:logbloc/config/locales.dart';
import 'package:logbloc/screens/settings/buy_app_box.dart';
import 'package:logbloc/screens/settings/preferences_settings.dart';
import 'package:logbloc/widgets/design/section_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';

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
            BuyAppBox(),

            SectionDivider(string: Tr.preferences.getString(context)),
            PreferencesSettings(),

            //SectionDivider(string: Tr.help.getString(context)),
            //HelpSettings(),
          ],
        ),
      ),
    );
  }
}
