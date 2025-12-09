import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/pools/items/item_class.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/screens/models/model_screen/model_screen.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/menu_button.dart';
import 'package:logbloc/widgets/design/none.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:flutter/material.dart';

final itemScreenKey = GlobalKey();
final dirtItemFlagPool = Pool<bool>(false);
final itemFormKey = GlobalKey<FormState>();

Item? globalItem;

class ItemScreen extends StatelessWidget {
  final bool readOnly;
  const ItemScreen({super.key, this.readOnly = false});

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

    final sortedFts = item.getSortedFts(staged: true).where((ft) {
      if (readOnly && ft.completeness == 0) return false;
      return true;
    });

    paintFt(Feature ft) {
      return FeatureWidget(
        key: UniqueKey(),
        lock: FeatureLock(model: true, record: readOnly),
        feature: ft,
        dirt: () {
          if (!dirtItemFlagPool.data) dirtItemFlagPool.set((_) => true);
        },
      );
    }

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
          SizedBox(width: 200, child: Txt(item.model!.name)),
          Exp(),

          Swimmer<bool>(
            pool: dirtItemFlagPool,
            builder: (context, dirty) => dirty
                ? IconButton(
                    onPressed: () {
                      item.save();

                      // for some reason pool.set method doesnt work here
                      dirtItemFlagPool.data = false;
                      dirtItemFlagPool.controller.sink.add(true);
                    },
                    icon: Icon(Icons.check_circle_outline),
                  )
                : None(),
          ),

          MenuButton(
            onSelected: (val) async {
              switch (val) {
                case 'go-to-model':
                  navLink(
                    rootIndex: 0,
                    screen: ModelScreen(model: item.model!),
                  );
                  break;

                case 'cancel':
                  await item.model!.cancelSchedule(
                    date: item.date,
                    schedule: item.schedule,
                  );
                  feedback('Entry cancelled', type: FeedbackType.success);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  break;

                case 'clean':
                  await warnDelete(
                    context,
                    delete: item.record!.delete,
                    msg:
                        'Are you sure you want this record to be deleted?',
                  );
                  break;
              }
            },
            options: [
              MenuOption(
                value: 'go-to-model',
                widget: ListTile(
                  title: Text('go to logbook'),
                  leading: Icon(Icons.arrow_forward),
                ),
              ),
              if (item.recordId == null)
                MenuOption(
                  value: 'cancel',
                  widget: ListTile(
                    title: Text('cancel for this date'),
                    leading: Icon(Icons.cancel_presentation),
                  ),
                )
              else
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
            Txt(
              hdate(DateTime.parse(item.date)),
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
