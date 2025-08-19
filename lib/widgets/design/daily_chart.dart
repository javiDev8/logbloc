import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/time_stats.dart';

class DailyChart extends StatelessWidget {
  final ChartOpts chartOpts;
  const DailyChart({super.key, required this.chartOpts});

  @override
  Widget build(BuildContext context) {
    final initPage = 9999999;
    final pageController = PageController(initialPage: initPage);
    DateTime initDate = DateTime.now();
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: pageController,
        itemBuilder: (context, pageIndex) {
          final date = initDate.add(Duration(days: pageIndex - initPage));
          final recs = chartOpts.recordFts.where(
            (r) => strDate(r['date']) == strDate(date),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(right: 20, top: 10),
                child: Txt(hdate(date), w: 8),
              ),
              Expanded(
                child: ListView(
                  children: recs
                      .map<Widget>(
                        (rec) => Column(
                          children: [
                            Text(rec['time']),
                            FeatureWidget(
                              lock: FeatureLock(model: true, record: true),
                              feature: featureSwitch(
                                parseType: 'class',
                                recordFt: rec,
                                entry: MapEntry<String, dynamic>(
                                  chartOpts.ft.key,
                                  chartOpts.ft.serialize(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
