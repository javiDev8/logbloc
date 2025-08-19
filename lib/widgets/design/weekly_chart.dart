import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/time_stats.dart';

class WeeklyChart extends StatelessWidget {
  final ChartOpts opts;
  final PageController pageController = PageController(initialPage: 1000);

  WeeklyChart({super.key, required this.opts});

  DateTime _getMondayOfWeek(DateTime date) {
    int daysToSubtract = date.weekday == 1 ? 0 : date.weekday - 1;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysToSubtract));
  }

  String _formatDayOfWeek(DateTime date) {
    const List<String> weekdays = [
      '', // Index 0 is empty for 1-indexed weekdays
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return weekdays[date.weekday];
  }

  @override
  Widget build(BuildContext context) {
    final recordFts = opts.recordFts;
    final getRecordValue = opts.getRecordValue;
    final String? unit = opts.unit;
    final ChartOperation operation = opts.operation;
    final bool? integer = opts.integer;

    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {},
        itemBuilder: (context, index) {
          final now = DateTime.now();
          final currentMonday = _getMondayOfWeek(now);
          final targetMonday = currentMonday.add(
            Duration(days: (index - pageController.initialPage) * 7),
          );

          final weekData = List.generate(7, (weekDayIndex) {
            final dayFtRecs = recordFts.where((rec) {
              final recDate = rec['date'];
              final weekDayDate = targetMonday.add(
                Duration(days: weekDayIndex),
              );
              return recDate.isAfter(
                    weekDayDate.subtract(Duration(days: 1)),
                  ) &&
                  recDate.isBefore(weekDayDate.add(Duration(days: 1)));
            });

            switch (operation) {
              case ChartOperation.average:
                if (dayFtRecs.isEmpty) return 0.0;
                return dayFtRecs.fold<double>(
                      0.0,
                      (sum, rec) => sum + getRecordValue(rec),
                    ) /
                    dayFtRecs.length;
              default:
                return dayFtRecs.fold(
                  0.0,
                  (sum, rec) => sum + getRecordValue(rec),
                );
            }
          });

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        months[targetMonday.month],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        targetMonday.year.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      barGroups: List.generate(7, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: weekData[i],
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
                              width: 40,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                          showingTooltipIndicators: [],
                        );
                      }),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 55,
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final dayIndex = value.toInt();
                              final day = targetMonday.add(
                                Duration(days: dayIndex),
                              );
                              final color =
                                  day.toString().split(' ')[0] ==
                                      DateTime.now().toString().split(
                                        ' ',
                                      )[0]
                                  ? seedColor
                                  : null;
                              return SideTitleWidget(
                                space: 4,
                                meta: meta,
                                child: Column(
                                  children: [
                                    Text(
                                      _formatDayOfWeek(day),
                                      style: TextStyle(color: color),
                                    ),
                                    Txt(
                                      color: color,
                                      day
                                          .toString()
                                          .split(' ')[0]
                                          .split('-')[2],
                                      w: 8,
                                      p: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem:
                              (group, groupIndex, rod, rodIndex) {
                                String val = rod.toY.toStringAsFixed(1);
                                if (integer != null && integer) {
                                  val = val.split('.')[0];
                                }
                                return BarTooltipItem(
                                  '$val ${unit ?? ''}',
                                  const TextStyle(color: Colors.white),
                                );
                              },
                        ),
                      ),
                      alignment: BarChartAlignment.spaceAround,
                      // set maxY to greatest value
                      maxY:
                          (recordFts.map(
                            (r) => getRecordValue(r),
                          )).reduce((a, b) => a > b ? a : b) *
                          1.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
