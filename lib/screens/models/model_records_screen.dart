import 'package:logbloc/pools/items/item_class.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/pools/records/records_pool.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/item_box.dart';
import 'package:flutter/material.dart';

class ModelRecordsScreen extends StatelessWidget {
  final Model model;
  const ModelRecordsScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wrapBar(
        backable: true,
        children: [Txt('${model.name} records')],
      ),
      body: Swimmer<Map<String, Rec>?>(
        pool: recordsPool,
        builder: (context, recs) {
          final records = recordsPool.getRecordsByModel(model.id);
          if (records == null) {
            return Center(child: CircularProgressIndicator());
          }
          if (records.isEmpty) {
            return Center(child: Text('no records'));
          }
          records.sort(
            (a, b) => DateTime.parse(
              a.schedule.day,
            ).compareTo(DateTime.parse(b.schedule.day)),
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: ListView(
              children: records
                  .map<Widget>(
                    (r) => Row(
                      children: [
                        ItemBox(
                          readOnly: true,
                          key: UniqueKey(),
                          fromRecords: true,
                          item: Item(
                            modelId: model.id,
                            recordId: r.id,
                            schedule: r.schedule,
                            date: r.schedule.day,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
