import 'package:logize/pools/theme_mode_pool.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final bool? lg;
  final IconData? lead;
  final Icon? leadi;
  final Color? overwrittenColor;
  final int variant;
  final bool filled;

  const Button(
    this.text, {
    required this.onPressed,
    super.key,
    this.lg,
    this.lead,
    this.leadi,
    this.overwrittenColor,
    this.variant = 0,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = lg == null || !lg! ? 10.0 : 50.0;

    final color = themeModePool.data == ThemeMode.light
        ? Colors.black
        : Colors.white;
    final txtStyle = TextStyle(fontWeight: FontWeight.w600, color: color);

    final cs = Theme.of(context).colorScheme;
    final variants = [
      cs.primaryContainer,
      cs.secondaryContainer,
      cs.tertiaryContainer,
    ];

    final style = ButtonStyle(
      side: WidgetStatePropertyAll(
        BorderSide(color: overwrittenColor ?? variants[variant], width: 2),
      ),
      backgroundColor: filled
          ? WidgetStateProperty.resolveWith(
              (_) => overwrittenColor ?? variants[variant],
            )
          : null,
    );
    final thereIsLead = (lead != null || leadi != null);

    if (thereIsLead && text != null) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: TextButton.icon(
          style: style,
          onPressed: onPressed,
          label: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, right: p),
            child: Text(text!, style: txtStyle),
          ),
          icon: Padding(
            padding: EdgeInsets.only(left: 10),
            child: leadi ?? Icon(lead, color: color),
          ),
        ),
      );
    }

    if (text != null && !thereIsLead) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: TextButton(
          onPressed: onPressed,
          style: style,
          child: Padding(
            padding: EdgeInsets.only(
              left: p,
              right: p,
              top: 10,
              bottom: 10,
            ),
            child: Text(text!, style: txtStyle),
          ),
        ),
      );
    }

    if (thereIsLead && text == null) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: IconButton(
          padding: EdgeInsets.all(15),
          onPressed: onPressed,
          style: style,
          icon: leadi ?? Icon(lead, color: color),
          color: color,
        ),
      );
    }

    throw Exception('lead and text missing on button');
  }
}
