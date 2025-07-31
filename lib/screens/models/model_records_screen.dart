import 'package:logize/pools/items/item_class.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/pools/records/records_pool.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/item_box.dart';
import 'package:flutter/material.dart';

class ModelRecordsScreen extends StatelessWidget {
  final Model model;
  const ModelRecordsScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Swimmer<Map<String, Rec>?>(
      pool: recordsPool,
      builder: (context, recs) {
        final records = recordsPool.getRecordsByModel(model.id);
        if (records == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (records.isEmpty) {
          return Center(child: Text('no records'));
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: ListView(
            children:
                records
                    .map<Widget>(
                      (r) => Row(
                        children: [
                          ItemBox(
                            key: UniqueKey(),
                            item: Item(
                              modelId: model.id,
                              recordId: r.id,
                              winnerSchRule: MapEntry('', 0),
                            ),
                            screenTitle: hdate(DateTime.parse(r.date)),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}
