import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/screen_index_pool.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/screens/daily/item_screen.dart';
import 'package:logize/screens/root_screen_switch.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

class ItemBox extends StatelessWidget {
  final Item item;
  final bool fromRecords;
  const ItemBox({super.key, required this.item, this.fromRecords = false});

  @override
  Widget build(BuildContext context) {
    final sortedFts = item.getSortedFts();

    final color = item.model?.color ?? Colors.grey;
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
              navPush(screen: ItemScreen());
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
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (!fromRecords)
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: item.recordId == null
                                ? Icon(Icons.circle_outlined)
                                : Icon(Icons.circle),
                          ),

                        fromRecords
                            ? Text(
                                hdate(
                                  DateTime.parse(
                                    item.record!.schedule.day,
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: 120,
                                child: Text(
                                  item.model!.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                              ),

                        Exp(),

                        if (!fromRecords)
                          ...sortedFts
                              .where((f) => !f.pinned)
                              .map<Widget>(
                                (ft) => Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: Icon(
                                    size: 20,
                                    featureSwitch(
                                          parseType: 'icon',
                                          ft: ft,
                                        )
                                        as IconData,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  ...sortedFts
                      .where((f) => f.pinned)
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
