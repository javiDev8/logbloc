import 'package:flutter/material.dart';

class ActButton extends StatelessWidget {
  final void Function() onPressed;
  final Icon icon;
  const ActButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton.large(
          onPressed: onPressed,
          child: Icon(icon.icon, color: Colors.white),
        ),
      ),
    );
  }
}
