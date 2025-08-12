import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/screen_index_pool.dart';
import 'package:logize/screens/daily/daily_screen.dart';
import 'package:logize/screens/models/models_screen.dart';
import 'package:logize/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RootScreen {
  final Widget screen;
  final GlobalKey<NavigatorState> nav;
  RootScreen({required this.screen, required this.nav});
}

final List<RootScreen> rootScreens =
    [ModelsScreen(), DailyScreen(), SettingsScreen()]
        .map<RootScreen>(
          (screen) =>
              RootScreen(screen: screen, nav: GlobalKey<NavigatorState>()),
        )
        .toList();

class RootScreenSwitch extends StatelessWidget {
  const RootScreenSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Swimmer<int>(
      pool: screenIndexPool,
      builder: (ctx, index) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (d, r) {
          final currentRootState =
              rootScreens[screenIndexPool.data].nav.currentState;
          if (currentRootState != null && currentRootState.canPop()) {
            currentRootState.pop();
            if (screenIndexPool.data == 0 && !currentRootState.canPop()) {
              modelEditPool.dirty = false;
            }
          } else {
            SystemNavigator.pop();
          }
        },

        child: IndexedStack(
          index: index,
          children: rootScreens
              .map<Widget>(
                (root) => Navigator(
                  key: root.nav,
                  onGenerateRoute: (route) {
                    if (route.name == '/') {
                      return MaterialPageRoute(
                        settings: route,
                        builder: (context) => root.screen,
                      );
                    } else {
                      return null; // handled ny non root navigation
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
