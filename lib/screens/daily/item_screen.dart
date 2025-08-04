import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/items/item_class.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:flutter/material.dart';

class ItemScreen extends StatelessWidget {
  final Item item;
  final GlobalKey<FormState> formKey;
  const ItemScreen({super.key, required this.item, required this.formKey});

  @override
  Widget build(BuildContext context) {
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
    );

    return Form(
      key: formKey,
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
    );
  }
}
