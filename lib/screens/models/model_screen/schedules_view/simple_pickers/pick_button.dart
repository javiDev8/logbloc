import 'package:flutter/material.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';

class PickButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool selected;
  final String str;
  final bool? isToday;

  const PickButton({
    super.key,
    required this.onPressed,
    required this.selected,
    required this.str,
    this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.tertiary.withAlpha(120);
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: selected ? WidgetStatePropertyAll(bgColor) : null,
      ),
      child: Text(
        str,
        style: TextStyle(
          fontWeight: isToday == true ? FontWeight.w900 : FontWeight.w600,
          fontSize: 12,
          color: isToday == true
              ? seedColor
              : themeModePool.data == ThemeMode.light
              ? Colors.black
              : selected
              ? (themeModePool.data == ThemeMode.dark
                    ? Colors.black
                    : Colors.white)
              : Colors.white,
        ),
      ),
    );
  }
}
