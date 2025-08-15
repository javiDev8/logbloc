import 'package:flutter/material.dart';
import 'package:logize/pools/theme_mode_pool.dart';

class PickButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool selected;
  final String str;
  const PickButton({
    super.key,
    required this.onPressed,
    required this.selected,
    required this.str,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: selected
            ? WidgetStatePropertyAll(
                Theme.of(context).colorScheme.tertiary,
              )
            : null,
      ),
      child: Text(
        str,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: selected
              ? (themeModePool.data == ThemeMode.dark
                    ? Colors.black
                    : Colors.white)
              : null,
        ),
      ),
    );
  }
}
