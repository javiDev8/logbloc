import 'package:logbloc/main.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:flutter/material.dart';

const seedColor = Color.fromARGB(255, 230, 173, 83);

ColorScheme genColorScheme(Brightness brightness) => ColorScheme.fromSeed(
  seedColor: seedColor,
  contrastLevel: 0,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  brightness: brightness,
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
    data = isDark == null || isDark ? ThemeMode.dark : ThemeMode.light;
  }

  changeMode(ThemeMode mode) async {
    data = mode;
    if (mode == ThemeMode.system) await sharedPrefs.remove(prefKey);
    await sharedPrefs.setBool(prefKey, mode == ThemeMode.dark);
    emit();
  }
}

final themeModePool = ThemeModePool(null);
