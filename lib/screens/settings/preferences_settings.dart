import 'package:logbloc/config/locales.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/widgets/design/button.dart';
//import 'package:logbloc/widgets/design/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class PreferencesSettings extends StatelessWidget {
  const PreferencesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(Tr.theme.getString(context)),
            Expanded(child: SizedBox()),
            Swimmer<ThemeMode?>(
              pool: themeModePool,
              builder: (context, theme) => Row(
                children: [
                  Button(
                    Tr.light.getString(context),
                    onPressed: () =>
                        themeModePool.changeMode(ThemeMode.light),
                    lead: Icons.light_mode,
                    filled: theme == ThemeMode.light,
                  ),
                  Button(
                    Tr.dark.getString(context),
                    onPressed: () =>
                        themeModePool.changeMode(ThemeMode.dark),

                    lead: Icons.dark_mode,
                    filled: theme == ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ],
        ),
        //Row(
        //  children: [
        //    Text(Tr.language.getString(context)),
        //    Expanded(child: SizedBox()),
        //    Dropdown(
        //      entries: [
        //        DropdownMenuEntry(value: 'en', label: 'english       '),
        //        DropdownMenuEntry(value: 'es', label: 'español       '),
        //      ],
        //      init:
        //          FlutterLocalization.instance.currentLocale!.languageCode,
        //      onSelect: (val) =>
        //          FlutterLocalization.instance.translate(val!),
        //    ),
        //  ],
        //),
      ],
    );
  }
}
