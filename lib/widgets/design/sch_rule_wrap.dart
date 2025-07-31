import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:flutter/material.dart';

class SchRuleWrap extends StatelessWidget {
  final Widget child;
  const SchRuleWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.tertiaryContainer;
    final color =
        themeModePool.data == ThemeMode.light ? c : endarkColor(c);
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: child,
    );
  }
}
