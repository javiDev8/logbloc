import 'package:logize/pools/screen_index_pool.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:flutter/material.dart';

navPush({required Widget screen}) => rootScreens[screenIndexPool.data]
    .nav
    .currentState!
    .push(MaterialPageRoute(builder: (_) => screen));

navPop() => rootScreens[screenIndexPool.data].nav.currentState!.pop();

navLink({required int rootIndex, required Widget screen}) {
  if (rootIndex == screenIndexPool.data) {
    navPush(screen: screen);
    return;
  }

  if (rootScreens[rootIndex].nav.currentState!.canPop()) {
    rootScreens[rootIndex].nav.currentState!.popUntil((r) => r.isFirst);
  }

  screenIndexPool.set((_) => rootIndex);
  rootScreens[rootIndex].nav.currentState!.push(
    MaterialPageRoute(builder: (_) => screen),
  );
}
