import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_screen/model_screen.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/utils/warn_dialogs.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/menu_button.dart';
import 'package:logize/widgets/design/none.dart';
import 'package:logize/widgets/design/topbar_wrap.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:flutter/material.dart';

final itemScreenKey = GlobalKey();
final dirtItemFlagPool = Pool<bool>(false);
final itemFormKey = GlobalKey<FormState>();

Item? globalItem;

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = globalItem!;
    // create deep copies of features
    item.stagedFeatures = Map.fromEntries(
      item.features.entries.map(
        (ft) => MapEntry(
          ft.key,
          featureSwitch(
                parseType: 'class',
                entry: MapEntry(ft.key, ft.value.serialize()),
              )
              as Feature,
        ),
      ),
    );

    final sortedFts = item.getSortedFts(staged: true);

    paintFt(Feature ft) => FeatureWidget(
      key: UniqueKey(),
      lock: FeatureLock(model: true, record: false),
      feature: ft,
      dirt: () {
        if (!dirtItemFlagPool.data) dirtItemFlagPool.set((_) => true);
      },
    );

    return Scaffold(
      key: itemScreenKey,
      appBar: wrapBar(
        backable: true,
        onBack: () async {
          if (!dirtItemFlagPool.data) return true;
          final res = await warnUnsavedChanges(
            context,
            save: globalItem!.save,
          );
          if (res == true) dirtItemFlagPool.data = false;
          return res ?? false;
        },
        children: [
          Txt(item.model!.name),
          Exp(),

          Swimmer<bool>(
            pool: dirtItemFlagPool,
            builder: (context, dirty) => dirty
                ? IconButton(
                    onPressed: () async {
                      if (itemFormKey.currentState!.validate()) {
                        final res = await item.save();
                        if (res) {
                          // set method somehow doesnt work here
                          dirtItemFlagPool.data = false;
                          dirtItemFlagPool.controller.sink.add(false);
                        }
                      }
                    },
                    icon: Icon(Icons.check_circle_outline),
                  )
                : None(),
          ),

          MenuButton(
            onSelected: (val) async {
              switch (val) {
                case 'clean':
                  await warnDelete(context, delete: item.record!.delete);
                  break;

                case 'go-to-model':
                  navLink(
                    rootIndex: 0,
                    screen: ModelScreen(model: item.model!),
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
      body: Form(
        key: itemFormKey,
        child: ListView(
          children: [
            if (item.date != null)
              Txt(
                hdate(DateTime.parse(item.date!)),
                s: 17,
                w: 6,
                a: TextAlign.center,
              ),

            // pinned
            ...sortedFts.where((f) => f.pinned).map<Widget>(paintFt),

            // not pinned
            ...sortedFts.where((f) => !f.pinned).map<Widget>(paintFt),
          ],
        ),
      ),
    );
  }
}
