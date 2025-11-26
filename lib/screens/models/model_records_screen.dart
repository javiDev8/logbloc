import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/pools/records/records_pool.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

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
            child: TimeStats(
              chartOpts: ChartOpts(
                isFt: false,
                integer: true,
                unit: '%',
                ft: Feature.empty('text'),
                getRecordValue: (sr) =>
                    Rec.fromMap(sr).completenessRate * 100,
                recordFts: records.map<Map<String, dynamic>>((r) {
                  final d = DateTime.parse(r.schedule.day);
                  Map<String, dynamic> sr = r.serialize();
                  sr['date'] = d;
                  return sr;
                }).toList(),
                operation: ChartOperation.average,
              ),
              showOptions: {
                'rate': (sr) => Rec.fromMap(sr).completenessRate * 100,
                'complete': (sr) => Rec.fromMap(sr).completeFts.toDouble(),
                'pending': (sr) =>
                    (Rec.fromMap(sr).features.length -
                            Rec.fromMap(sr).completeFts)
                        .toDouble(),
              },
            ),
          );
        },
      ),
    );
  }
}
