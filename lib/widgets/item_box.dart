import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/pools/items/item_class.dart';
import 'package:logbloc/pools/screen_index_pool.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/daily/item_screen.dart';
import 'package:logbloc/screens/root_screen_switch.dart';
import 'package:logbloc/utils/color_convert.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/nav.dart';
//import 'package:logbloc/widgets/design/exp.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/txt.dart';

class ItemBox extends StatelessWidget {
  final Item item;
  final bool fromRecords;
  final bool readOnly;
  const ItemBox({
    super.key,
    required this.item,
    this.fromRecords = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final sortedFts = item.getSortedFts();

    final color = item.model?.color ?? Colors.grey;

    final pinnedFts = [];
    final unpinnedFts = [];
    for (final ft in sortedFts) {
      if (ft.pinned) {
        pinnedFts.add(ft);
      } else {
        unpinnedFts.add(ft);
      }
    }

    final splitHead =
        pinnedFts.isNotEmpty ||
        unpinnedFts.length > 5 ||
        item.model!.name.length > 15;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              // avoid duplicated item screen
              if (itemScreenKey.currentState != null) {
                if (screenIndexPool.data == 0) {
                  rootScreens[1].nav.currentState!.pop();
                } else if (screenIndexPool.data == 1) {
                  rootScreens[0].nav.currentState!.pop();
                }
                // yes flutter cant handle it
                await Future.delayed(Duration(milliseconds: 150));
              }
              globalItem = item;
              navPush(screen: ItemScreen(readOnly: readOnly));
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (themeModePool.data == ThemeMode.light
                    ? enbrightColor(color)
                    : endarkColor(color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: fromRecords
                              ? Text(
                                  hdate(
                                    DateTime.parse(
                                      item.record!.schedule.day,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: splitHead ? 270 : 120,
                                  child: Text(
                                    item.model!.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(left: 20),
                            child: LinearProgressIndicator(
                              value: item.record == null
                                  ? 0
                                  : item.record!.completenessRate,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        Txt(
                          '${item.record?.completeFts ?? 0}/${item.features.length}',
                          w: 6,
                        ),

                        //if (!fromRecords && !splitHead) ...unPinnedFtsWids,
                      ],
                    ),
                  ),

                  if (item.record != null)
                    ...pinnedFts
                        .where((ft) => !ft.isEmpty)
                        .map<Widget>(
                          (ft) => FeatureWidget(
                            lock: FeatureLock(model: true, record: true),
                            feature: ft,
                          ),
                        ),
                  //
                  //if (splitHead)
                  //  Padding(
                  //    padding: EdgeInsetsGeometry.only(
                  //      left: 20,
                  //      right: 20,
                  //      bottom: 15,
                  //    ),
                  //    child: Row(
                  //      mainAxisAlignment: MainAxisAlignment.end,
                  //      children: [
                  //        Expanded(
                  //          child: Wrap(
                  //            alignment: WrapAlignment.end,
                  //            children: [
                  //              if (pinnedFts.isNotEmpty &&
                  //                  unpinnedFts.isNotEmpty)
                  //                Text('...  '),
                  //              ...unPinnedFtsWids,
                  //            ],
                  //          ),
                  //        ),
                  //      ],
                  //    ),
                  //  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
