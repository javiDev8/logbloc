import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String text;
  const Header(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}
