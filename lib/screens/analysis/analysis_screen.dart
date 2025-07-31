import 'package:logize/pools/items/items_by_day_pool.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/records/record_class.dart';
import 'package:logize/pools/records/records_pool.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/weekly_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Swimmer(
      pool: modelsPool,
      builder:
          // todo: implement multi swimmer
          (ctx, models) => Swimmer<Map<String, Rec>?>(
            pool: recordsPool,
            builder: (ctx, recs) {
              final nowStr = strDate(DateTime.now());
              final items = itemsByDayPool.data[nowStr];
              if (items == null || recs == null) {
                recordsPool.retrieve();
                itemsByDayPool.retrieve(nowStr);
                return Center(child: CircularProgressIndicator());
              }
              final emptyItems = items
                  .where((item) => item.recordId == null)
                  .fold<double>(0.0, (double a, b) => a + 1);

              final filledItems = items
                  // filled items only
                  .where((item) => item.recordId != null)
                  .fold<double>(0.0, (double a, b) => a + 1);

              return ListView(
                children: [
                  SectionDivider(string: 'today items'),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 8,
                              sections: [
                                PieChartSectionData(
                                  title:
                                      emptyItems.toString().split('.')[0],
                                  value: emptyItems,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                ),
                                PieChartSectionData(
                                  title:
                                      filledItems.toString().split('.')[0],
                                  value: filledItems,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.tertiaryContainer,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Wrap(
                                direction: Axis.vertical,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer,
                                      ),
                                      Text('empty'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color:
                                            Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                      ),
                                      Text('filled'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SectionDivider(string: 'week records'),
                  WeeklyChart(
                    unit: 'records',
                    integer: true,
                    recordFts:
                        recs.entries
                            .map(
                              (recEntry) => {
                                'val': 1.0,
                                'date': DateTime.parse(
                                  recEntry.value.date,
                                ),
                              },
                            )
                            .toList(),
                    getRecordValue: (r) => r['val'],
                  ),
                ],
              );
            },
          ),
    );
  }
}
