import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/button.dart';

class WelcomePage extends StatelessWidget {
  final int index;
  final bool withNextBtn;
  final PageController controller;
  final Widget child;

  const WelcomePage({
    super.key,
    required this.withNextBtn,
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
