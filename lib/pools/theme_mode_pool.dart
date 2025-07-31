import 'package:logize/main.dart';
import 'package:logize/pools/pools.dart';
import 'package:flutter/material.dart';

const seedColor = Color.fromARGB(1, 230, 173, 83);

ColorScheme genColorScheme(Brightness brightness) => ColorScheme.fromSeed(
  seedColor: seedColor,
  //seedColor: Colors.amber,
  contrastLevel: 0,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  brightness: brightness,
  //secondary: Color.fromARGB(1, 230, 127, 83),
  //secondaryContainer: Color.fromRGBO(242, 174, 128, 1),
);

final detaTheme = ThemeData(colorScheme: genColorScheme(Brightness.light));
final detaDarkTheme = ThemeData(
  colorScheme: genColorScheme(Brightness.dark),
);

class ThemeModePool extends Pool<ThemeMode?> {
  final String prefKey = 'dark-mode';

  ThemeModePool(super.def);
  init() async {
    final isDark = await sharedPrefs.getBool(prefKey);
    if (isDark == null) {
      data = ThemeMode.system;
      return;
    }
    if (isDark) data = ThemeMode.dark;
    if (!isDark) data = ThemeMode.light;
  }

  changeMode(ThemeMode mode) async {
    data = mode;
    if (mode == ThemeMode.system) await sharedPrefs.remove(prefKey);
    await sharedPrefs.setBool(prefKey, mode == ThemeMode.dark);
    emit();
  }
}

final themeModePool = ThemeModePool(null);
