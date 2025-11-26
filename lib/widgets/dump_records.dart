import 'package:flutter/cupertino.dart';
import 'package:logbloc/pools/items/item_class.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/widgets/item_box.dart';

List<Widget> dumpRecrods(List<Rec> records) {
  if (records.isEmpty) {
    return [];
  }
  records.sort(
    (a, b) => DateTime.parse(
      a.schedule.day,
    ).compareTo(DateTime.parse(b.schedule.day)),
  );
  return records
      .map<Widget>(
        (r) => Row(
          children: [
            ItemBox(
              readOnly: true,
              key: UniqueKey(),
              fromRecords: true,
              item: Item(
                modelId: records.first.modelId,
                recordId: r.id,
                schedule: r.schedule,
                date: r.schedule.day,
              ),
            ),
          ],
        ),
      )
      .toList();
}
