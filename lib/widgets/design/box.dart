import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget? child;
  final Color? color;
  const Box({super.key, this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color ?? Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [child ?? Placeholder(), SizedBox(height: 100)],
          ),
        ),
      ),
    );
  }
}
