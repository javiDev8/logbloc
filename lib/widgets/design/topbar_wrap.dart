import 'package:flutter/material.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/screen_index_pool.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/root_screen_switch.dart';

PreferredSize wrapBar({
  required bool backable,
  required List<Widget> children,
  Future<bool> Function()? onBack,
}) {
  final rootIndex = screenIndexPool.data;
  final controller = ScrollController();
  return PreferredSize(
    preferredSize: Size.fromHeight(80),
    child: Padding(
      padding: EdgeInsetsGeometry.only(left: 15, right: 15, top: 50, bottom: 5),
      child: Swimmer<ThemeMode>(
        pool: themeModePool,
        builder: (context, theme) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              if (controller.hasClients &&
                  controller.position.maxScrollExtent > 0) {
                controller.jumpTo(controller.position.maxScrollExtent);
              }
            } catch (e) {
              // ignore
            }
          });
          return DefaultTextStyle(
            style: TextStyle(
              fontSize: 20,
              color: theme == ThemeMode.light ? Colors.black : Colors.white,
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (backable)
                  IconButton(
                    onPressed: () async {
                      if (onBack != null && !(await onBack())) return;
                      rootScreens[rootIndex].nav.currentState?.pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
