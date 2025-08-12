import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/pools/records/records_pool.dart';
import 'package:logize/widgets/design/topbar_wrap.dart';
import 'package:logize/widgets/design/txt.dart';

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
        children: [Txt('${mFt.title} stats')],
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
          return Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                child: Row(
                  children: [
                    Icon(
                      featureSwitch(parseType: 'icon', ftType: mFt.type),
                    ),
                    featureSwitch(parseType: 'label', ftType: mFt.type),
                  ],
                ),
              ),
              featureSwitch(parseType: 'stats', ft: mFt, ftRecs: ftRecs),
            ],
          );
        },
      ),
    );
  }
}
