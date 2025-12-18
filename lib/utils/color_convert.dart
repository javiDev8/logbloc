import 'package:flutter/material.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';

enbrightColor(Color color) => Color.lerp(color, Colors.white, 0.4);

endarkColor(Color color) => Color.lerp(color, Colors.black, 0.4);

enThemeColor(Color color) =>
    themeModePool.data == ThemeMode.dark
    ? endarkColor(color)
    : enbrightColor(color);
