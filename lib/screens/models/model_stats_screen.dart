import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/pools/records/records_pool.dart';
import 'package:flutter/material.dart';

class ModelStatsScreen extends StatelessWidget {
  final Model model;
  const ModelStatsScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Swimmer<Map<String, Rec>?>(
      pool: recordsPool,
      builder: (context, recs) {
        final modelRecs = recordsPool.getRecordsByModel(model.id);
        if (modelRecs == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (modelRecs.isEmpty) {
          return Center(child: Text('no records'));
        }
        return ListView(
          children: model.features.entries.map<Widget>((mFt) {
            final ftRecs = modelRecs
                .where((rec) => rec.features.keys.contains(mFt.key))
                .map(
                  (rec) => {
                    'date': DateTime.parse(rec.date),
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
                        featureSwitch(
                          parseType: 'icon',
                          ftType: mFt.value.type,
                        ),
                      ),
                      featureSwitch(
                        parseType: 'label',
                        ftType: mFt.value.type,
                      ),
                    ],
                  ),
                ),
                featureSwitch(
                  parseType: 'stats',
                  ft: mFt.value,
                  ftRecs: ftRecs,
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
