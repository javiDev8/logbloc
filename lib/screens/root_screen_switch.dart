import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/screen_index_pool.dart';
import 'package:logbloc/screens/daily/daily_screen.dart';
import 'package:logbloc/screens/daily/item_screen.dart';
import 'package:logbloc/screens/models/model_screen/model_screen.dart';
import 'package:logbloc/screens/models/models_screen.dart';
import 'package:logbloc/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logbloc/utils/warn_dialogs.dart';

class RootScreen {
  final Widget screen;
  final GlobalKey<NavigatorState> nav;
  RootScreen({required this.screen, required this.nav});
}

final List<RootScreen> rootScreens =
    [ModelsScreen(key: UniqueKey()), DailyScreen(), SettingsScreen()]
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
        onPopInvokedWithResult: (d, r) async {
          final currentRootState =
              rootScreens[screenIndexPool.data].nav.currentState;

          if (currentRootState != null && currentRootState.canPop()) {
            // non root page

            // nav hooks
            switch (screenIndexPool.data) {
              case 0:
                // models root
                if (modelScreenKey.currentContext != null &&
                    modelEditPool.dirty) {
                  final res = await warnUnsavedChanges(
                    context,
                    save: modelEditPool.save,
                  );

                  if (res != true) return;
                }

                currentRootState.pop();
                if (!currentRootState.canPop()) {
                  modelEditPool.dirty = false;
		  modelEditPool.editingSchs = [];
		  modelEditPool.editingFts = [];
                }

                break;

              case 1:
                // daily root
                if (itemScreenKey.currentContext != null &&
                    dirtItemFlagPool.data) {
                  final res = await warnUnsavedChanges(
                    context,
                    save: globalItem!.save,
                  );
                  if (res == true) {
                    currentRootState.pop();
                    dirtItemFlagPool.data = false;
                  }
                } else {
                  currentRootState.pop();
                }
                break;
            }
          } else {
            //root
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
