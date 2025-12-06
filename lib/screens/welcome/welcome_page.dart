import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/txt.dart';

class WelcomePage extends StatelessWidget {
  final int index;
  final bool withNextBtn;
  final PageController controller;
  final Widget child;
  final String title;

  const WelcomePage({
    super.key,
    required this.withNextBtn,
    required this.index,
    required this.controller,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 100, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(children: [Txt(title, w: 8, s: 40)]),
          Expanded(child: child),

          if (withNextBtn)
            Row(
              children: [
                Expanded(
                  child: Button(
                    'continue',
                    onPressed: () => controller.animateToPage(
                      index + 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutSine,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
