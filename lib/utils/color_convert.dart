import 'package:flutter/material.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';

enbrightColor(Color color) => Color.lerp(color, Colors.white, 0.5);

endarkColor(Color color) => Color.lerp(color, Colors.black, 0.5);

enThemeColor(Color color, BuildContext context) =>
    themeModePool.data == ThemeMode.dark
    ? endarkColor(color)
    : enbrightColor(color);
