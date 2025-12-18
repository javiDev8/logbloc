import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/pools/records/records_pool.dart';
import 'package:logbloc/screens/models/model_screen/feature_stats_screen.dart';
import 'package:logbloc/utils/color_convert.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/section_divider.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class ModelRecordsScreen extends StatelessWidget {
  final Model model;
  const ModelRecordsScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    double getCompleteRate(sr) => Rec.fromMap(sr).completeness * 100;

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
          return SingleChildScrollView(
            child: Column(
              children: [
                TimeStats(
                  chartOpts: ChartOpts(
                    mode: 'calendar',
                    getDayColor: (_) => model.color != null
                        ? enThemeColor(model.color!)
                        : null,
                    isFt: false,
                    integer: true,
                    unit: '%',
                    ft: Feature.empty('text'),
                    getRecordValue: getCompleteRate,
                    recordFts: records.map<Map<String, dynamic>>((r) {
                      final d = DateTime.parse(r.schedule.day);
                      Map<String, dynamic> sr = r.serialize();
                      sr['date'] = d;
                      return sr;
                    }).toList(),
                    operation: ChartOperation.average,
                  ),
                  showOptions: {
                    'complete rate (%)': getCompleteRate,
                    'records': (_) => 1,
                  },
                ),

                SectionDivider(string: 'Feature records'),
                ...model.features.values
                    .where((f) => f.type != 'reminder')
                    .map(
                      (ft) => ListTile(
                        onTap: () => navPush(
                          screen: FeatureStatsScreen(ftKey: ft.key),
                        ),
                        title: Text(ft.title),
                        leading: Icon(
                          featureSwitch(
                            parseType: 'icon',
                            ftType: ft.type,
                          ),
                        ),
                      ),
                    ),

                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
