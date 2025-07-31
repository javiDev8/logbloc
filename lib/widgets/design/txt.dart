import 'package:flutter/material.dart';

class Txt extends StatelessWidget {
  final String text;
  final EdgeInsets? p; // padding
  final int? w; // weight
  final double? s; // size
  final TextAlign? a;

  final weights = [
    FontWeight.w100,
    FontWeight.w200,
    FontWeight.w300,
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900,
  ];

  Txt(this.text, {super.key, this.w, this.p, this.s, this.a});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: p ?? EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: a,
        style: TextStyle(
          fontWeight: w == null ? null : weights[w!],
          fontSize: s,
        ),
      ),
    );
  }
}
