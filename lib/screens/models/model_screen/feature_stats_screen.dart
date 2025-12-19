import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/pools/records/records_pool.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';

class FeatureStatsScreen extends StatelessWidget {
  final String ftKey;
  const FeatureStatsScreen({super.key, required this.ftKey});

  @override
  Widget build(BuildContext context) {
    final model = modelEditPool.data;
    final mFt = model.features[ftKey]!;
    return Scaffold(
      appBar: wrapBar(
        backable: true,
        children: [
          Icon(featureSwitch(parseType: 'icon', ftType: mFt.type)),
          Txt('${model.name} / ${mFt.title}'),
        ],
      ),
      body: Swimmer<Map<String, Rec>?>(
        pool: recordsPool,
        builder: (context, recs) {
          final modelRecs = recordsPool.getRecordsByModel(model.id);
          if (modelRecs == null) {
            return Center(child: CircularProgressIndicator());
          }
          if (modelRecs.isEmpty) {
            return Center(child: Text('no records'));
          }

          final ftRecs = modelRecs
              .where((rec) => rec.features.keys.contains(mFt.key))
              .map(
                (rec) => {
                  'date': DateTime.parse(rec.schedule.day),
                  ...rec.features[mFt.key] as Map<String, dynamic>,
                },
              )
              .toList();
          ftRecs.sort((a, b) => a['date'].compareTo(b['date']));
          return featureSwitch(parseType: 'stats', ft: mFt, ftRecs: ftRecs);
        },
      ),
    );
  }
}
