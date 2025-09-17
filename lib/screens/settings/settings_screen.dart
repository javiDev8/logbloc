import 'package:logbloc/config/locales.dart';
import 'package:logbloc/screens/settings/about_section.dart';
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
      appBar: wrapBar(backable: false, children: [Txt('etc')]),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 10),
        child: ListView(
          children: [
            StatefulBuilder(
              builder: (context, setState) =>
                  BuyAppBox(reload: () => setState(() {})),
            ),

            SectionDivider(string: Tr.preferences.getString(context)),
            PreferencesSettings(),

            SectionDivider(string: 'about'),
            AboutSection(),
          ],
        ),
      ),
    );
  }
}
