import 'package:logize/pools/screen_index_pool.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:flutter/material.dart';

navPush({
  required BuildContext context,
  required Widget screen,
  required Widget title,
}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  // ignore: sized_box_for_whitespace
  topbarPool.pushTitle(Container(width: 290, child: title));
}

navPop({BuildContext? context}) {
  if (context != null) {
    Navigator.of(context);
  } else {
    rootScreens[screenIndexPool.data].nav.currentState!.pop();
  }
  topbarPool.popTitle();
}

navLink({
  required int rootIndex,
  required Widget screen,
  required Widget title,
}) {
  if (rootScreens[rootIndex].nav.currentState!.canPop()) {
    rootScreens[rootIndex].nav.currentState!.popUntil((r) => r.isFirst);
    topbarPool.titles[rootIndex] = TopbarPool.initTitles[rootIndex];
  }

  screenIndexPool.set((_) => rootIndex);
  rootScreens[rootIndex].nav.currentState!.push(
    MaterialPageRoute(builder: (_) => screen),
  );

  topbarPool.setRootIndex(rootIndex);
  topbarPool.pushTitle(
    // ignore: sized_box_for_whitespace
    Container(width: 290, child: title),
  );
}
