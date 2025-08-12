import 'package:flutter/material.dart';
import 'package:logize/pools/screen_index_pool.dart';
import 'package:logize/screens/root_screen_switch.dart';

PreferredSize wrapBar({
  required bool backable,
  required List<Widget> children,
}) {
  final rootIndex = screenIndexPool.data;
  return PreferredSize(
    preferredSize: Size(290, 80),
    child: Padding(
      padding: EdgeInsetsGeometry.only(
        left: 15,
        right: 15,
        top: 30,
        bottom: 5,
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 20),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (backable)
              IconButton(
                onPressed: () {
                  rootScreens[rootIndex].nav.currentState!.pop();
                },
                icon: Icon(Icons.arrow_back),
              ),
            ...children,
          ],
        ),
      ),
    ),
  );
}
