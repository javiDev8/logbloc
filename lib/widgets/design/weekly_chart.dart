import 'package:logize/utils/fmt_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  final PageController pageController = PageController(initialPage: 1000);
  final double Function(Map<String, dynamic>) getRecordValue;
  final List<Map<String, dynamic>> recordFts;
  final String? unit;
  final bool? integer;

  WeeklyChart({
    super.key,
    required this.recordFts,
    required this.getRecordValue,
    this.unit,
    this.integer,
  });

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
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {},
        itemBuilder: (context, index) {
          final now = DateTime.now();
          final currentMonday = _getMondayOfWeek(now);
          final targetMonday = currentMonday.add(
            Duration(days: (index - pageController.initialPage) * 7),
          );

          final weekData = List.generate(
            7,
            (weekDayIndex) => recordFts
                .where((rec) {
                  final recDate = rec['date'];
                  final weekDayDate = targetMonday.add(
                    Duration(days: weekDayIndex),
                  );
                  return recDate.isAfter(
                        weekDayDate.subtract(Duration(days: 1)),
                      ) &&
                      recDate.isBefore(weekDayDate.add(Duration(days: 1)));
                })
                .fold(0.0, (sum, rec) => sum + getRecordValue(rec)),
          );

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
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.tertiaryContainer,
                              width: 30,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                          showingTooltipIndicators: [],
                        );
                      }),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 50,
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final dayIndex = value.toInt();
                              final day = targetMonday.add(
                                Duration(days: dayIndex),
                              );
                              return SideTitleWidget(
                                space: 4,
                                meta: meta,
                                child: Column(
                                  children: [
                                    Text(_formatDayOfWeek(day)),
                                    Text(
                                      day
                                          .toString()
                                          .split(' ')[0]
                                          .split('-')[2],
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
                          getTooltipItem: (
                            group,
                            groupIndex,
                            rod,
                            rodIndex,
                          ) {
                            String val = rod.toY.toStringAsFixed(1);
                            if (integer != null && integer!) {
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
                      maxY: weekData.reduce((a, b) => a > b ? a : b) * 1.2,
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
