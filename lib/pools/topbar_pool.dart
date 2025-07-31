import 'package:logize/config/locales.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/screen_index_pool.dart';
import 'package:logize/screens/daily/daily_screen.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:logize/widgets/design/pretty_date.dart';
import 'package:flutter/material.dart';

class TopbarPool extends Pool<Widget> {
  List<List<Widget>> titles;
  int rootIndex;
  TopbarPool()
    : titles = deepCopyInitTitles(),
      rootIndex = screenIndexPool.data,
      super(initTitles[screenIndexPool.data].last);

  static final initTitles = [
    [TrText(Tr.models)],
    [PrettyDate(date: initDate)],
    [TrText(Tr.analysis)],
    [TrText(Tr.settings)],
  ];

  static deepCopyInitTitles() =>
      initTitles.map((root) => [...root]).toList();

  get rootTitles => titles[rootIndex];

  clean() {
    titles = deepCopyInitTitles();
    makeBar();
  }

  setCurrentTitle(Widget title) {
    rootTitles.last = title;
    makeBar();
  }

  makeBar() {
    Widget title = rootTitles.last;
    if (rootTitles.length > 1) {
      data = Row(
        children: [
          Builder(
            builder:
                (context) => IconButton(
                  onPressed: () {
                    popTitle();
                    rootScreens[rootIndex].nav.currentState!.pop();
                  },
                  icon: Icon(Icons.arrow_back),
                ),
          ),
          title,
        ],
      );
    } else {
      data = title;
    }
    emit();
  }

  setRootIndex(int index) {
    rootIndex = index;
    makeBar();
  }

  pushTitle(Widget title) {
    rootTitles.add(title);
    makeBar();
  }

  popTitle() {
    rootTitles.removeLast();
    makeBar();
  }
}

final topbarPool = TopbarPool();
