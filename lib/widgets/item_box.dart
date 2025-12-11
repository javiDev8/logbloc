import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/pools/items/item_class.dart';
import 'package:logbloc/pools/screen_index_pool.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/daily/item_screen.dart';
import 'package:logbloc/screens/root_screen_switch.dart';
import 'package:logbloc/utils/color_convert.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:flutter/material.dart';

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
                    padding: EdgeInsets.all(22),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                        ),

                        if (item.record?.completeness == 1)
                          Icon(Icons.check)
                        else
                        // check that item record completeness is not NaN
                        if (item.record?.completeness.toString() !=
                                'NaN' &&
                            !(item.model!.features.length == 1 &&
                                item.model!.features.values.first.type ==
                                    'reminder')) ...[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 10,
                              ),
                              child: LinearProgressIndicator(
                                value: item.record == null
                                    ? 0
                                    : item.record!.completeness,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${((item.record?.completeness ?? 0) * 100).toInt()}%',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (item.record != null)
                    ...pinnedFts
                        .where((ft) => ft.completeness > 0)
                        .map<Widget>(
                          (ft) => FeatureWidget(
                            lock: FeatureLock(model: true, record: true),
                            feature: ft,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
