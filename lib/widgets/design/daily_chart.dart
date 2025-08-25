import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/pools/theme_mode_pool.dart';
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

          final n = DateTime.now();
          final dayColor =
              date.day == n.day &&
                  date.month == n.month &&
                  date.year == n.year
              ? seedColor
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(right: 20, top: 10),
                child: Text(
                  hdate(date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dayColor,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: recs
                      .map<Widget>(
                        (rec) => Padding(
                          padding: EdgeInsetsGeometry.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Txt('at ${rec['time']}', w: 7),
                              FeatureWidget(
                                lock: FeatureLock(
                                  model: true,
                                  record: true,
                                ),
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
