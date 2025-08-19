import 'package:flutter/material.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logize/widgets/time_stats.dart';

class MonthlyChart extends StatelessWidget {
  final ChartOpts opts;
  final PageController pageController = PageController(initialPage: 1000);

  MonthlyChart({super.key, required this.opts});

  DateTime getFirstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  int getDaysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

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
        itemBuilder: (context, index) {
          final now = DateTime.now();
          final targetMonth = DateTime(
            now.year,
            now.month + (index - pageController.initialPage),
            1,
          );
          final firstDayOfMonth = getFirstDayOfMonth(targetMonth);
          final daysInMonth = getDaysInMonth(targetMonth);

          final monthData = List.generate(daysInMonth, (dayIndex) {
            final currentDate = firstDayOfMonth.add(
              Duration(days: dayIndex),
            );
            final dayFtRecs = recordFts.where((rec) {
              final recDate = rec['date'] as DateTime;
              return recDate.year == currentDate.year &&
                  recDate.month == currentDate.month &&
                  recDate.day == currentDate.day;
            });

            if (dayFtRecs.isEmpty) return 0.0;
            switch (operation) {
              case ChartOperation.average:
                return dayFtRecs.fold<double>(
                      0.0,
                      (sum, rec) => sum + getRecordValue(rec),
                    ) /
                    dayFtRecs.length;
              default:
                ChartOperation.add;
                return dayFtRecs.fold<double>(
                  0.0,
                  (sum, rec) => sum + getRecordValue(rec),
                );
            }
          });

          final maxYValue = recordFts.isNotEmpty
              ? (recordFts.map(
                      (r) => getRecordValue(r),
                    )).reduce((a, b) => a > b ? a : b) *
                    1.2
              : 10.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        months[firstDayOfMonth.month],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        firstDayOfMonth.year.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(daysInMonth, (index) {
                            return FlSpot(
                              (index + 1).toDouble(),
                              monthData[index],
                            );
                          }),
                          color: Theme.of(context).colorScheme.tertiary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        show: true,

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final day = value.toInt();
                              final bool isToday =
                                  targetMonth.year == now.year &&
                                  targetMonth.month == now.month &&
                                  day == now.day;
                              final bool shouldShowTitle =
                                  (day % 7 == 1) || isToday;

                              if (!shouldShowTitle) {
                                return const SizedBox.shrink();
                              }

                              return SideTitleWidget(
                                meta: meta,
                                space: 8.0,
                                child: Text(
                                  day.toString(),
                                  style: TextStyle(
                                    color: isToday
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                        : null,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        //bottomTitles: AxisTitles(
                        //  sideTitles: SideTitles(
                        //    showTitles: true,
                        //    reservedSize: 30,
                        //    interval: 1,
                        //    getTitlesWidget: (value, meta) {
                        //      final day = value.toInt();
                        //      if (day % 7 == 1 || daysInMonth <= 10) {
                        //        return SideTitleWidget(
                        //          meta: meta,
                        //          space: 8.0,
                        //          child: Text(day.toString()),
                        //        );
                        //      }
                        //      return const SizedBox.shrink();
                        //    },
                        //  ),
                        //),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              String val = spot.y.toStringAsFixed(1);
                              if (integer == true) {
                                val = spot.y.toInt().toString();
                              }
                              return LineTooltipItem(
                                '${spot.x.toInt()}  $val${unit ?? ''}',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      minX: 1,
                      maxX: daysInMonth.toDouble(),
                      minY: 0,
                      maxY: maxYValue,
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
