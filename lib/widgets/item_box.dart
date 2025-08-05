import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/screens/daily/item_screen.dart';
import 'package:logize/screens/models/full_model_screen.dart';
import 'package:logize/screens/models/model_lead_menu_widget.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/menu_button.dart';

import 'package:flutter/material.dart';

class ItemBox extends StatelessWidget {
  final Item item;
  final String screenTitle;
  const ItemBox({
    super.key,
    required this.item,
    required this.screenTitle,
  });

  @override
  Widget build(BuildContext context) {
    final itemFormKey = GlobalKey<FormState>();

    final sortedFts = item.getSortedFts();

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              navPush(
                context: context,
                screen: ItemScreen(item: item, formKey: itemFormKey),
                title: Row(
                  children: [
                    Text(screenTitle),
                    Exp(),
                    IconButton(
                      onPressed: () async {
                        if (itemFormKey.currentState!.validate()) {
                          await item.save();
                          navPop();
                        }
                      },
                      icon: Icon(Icons.save),
                    ),

                    MenuButton(
                      onSelected: (val) async {
                        switch (val) {
                          case 'clean':
                            await item.record!.delete();
                            navPop();
                            break;

                          case 'go-to-model':
                            navLink(
                              rootIndex: 0,
                              screen: FullModelScreen(model: item.model!),
                              title: Row(
                                children: [
                                  Text(item.model!.name),
                                  Exp(),
                                  ModelLeadMenuWidget(
                                    model: item.model!,
                                    parentCtx: context,
                                  ),
                                ],
                              ),
                            );

                            break;
                        }
                      },
                      options: [
                        MenuOption(
                          value: 'go-to-model',
                          widget: ListTile(
                            title: Text('go to model'),
                            leading: Icon(Icons.arrow_forward),
                          ),
                        ),
                        if (item.recordId != null)
                          MenuOption(
                            value: 'clean',
                            widget: ListTile(
                              title: Text('clean'),
                              leading: Icon(Icons.close),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: themeModePool.data == ThemeMode.dark
                    ? (item.model?.color != null
                          ? item.model!.color
                          : Color.fromRGBO(100, 100, 100, 1))
                    : (item.model?.color != null
                          ? enbrightColor(item.model!.color!)
                          : enbrightColor(Colors.grey)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (item.date != null)
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: item.recordId == null
                                ? Icon(Icons.circle_outlined)
                                : Icon(Icons.circle),
                          ),

                        item.date == null && item.record != null
                            ? Text(
                                hdate(
                                  DateTime.parse(
                                    item.record!.schedule.day,
                                  ),
                                ),
                              )
                            : Text(
                                item.modelName ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                        Exp(),

                        if (item.date != null)
                          ...sortedFts
                              .where((f) => !f.pinned)
                              .map<Widget>(
                                (ft) => Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: Icon(
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
