import 'package:flutter/material.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logbloc/widgets/dump_ft_records.dart';
import 'package:logbloc/widgets/time_stats.dart';

class MonthlyChart extends StatelessWidget {
  final ChartOpts opts;
  final bool dump;
  final PageController pageController = PageController(initialPage: 1000);

  MonthlyChart({super.key, required this.opts, required this.dump});

  DateTime getFirstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  int getDaysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final recordFts = opts.recordFts;
    final getRecordValue = opts.getRecordValue;
    final ChartOperation operation = opts.operation;
    final bool? integer = opts.integer;

    return SizedBox(
      height: dump ? 500 : 450,
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

            return operate(dayFtRecs, operation, getRecordValue);
          });

          final n = DateTime.now();
          final monthColor =
              firstDayOfMonth.month == n.month &&
                  firstDayOfMonth.year == n.year
              ? seedColor
              : null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${months[firstDayOfMonth.month]}  '
                        '${firstDayOfMonth.year.toString()}',
                        style: TextStyle(
                          color: monthColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                if (dump)
                  Expanded(
                    child: ListView(
                      children:
                          dumpFtRecords(
                                ft: opts.ft,
                                recordFts: recordFts
                                    .where(
                                      (rec) =>
                                          rec['date'].year ==
                                              targetMonth.year &&
                                          rec['date'].month ==
                                              targetMonth.month,
                                    )
                                    .toList(),
                              )
                              .map(
                                (w) => Row(children: [Expanded(child: w)]),
                              )
                              .toList(),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
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
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
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
                                      color: isToday ? seedColor : null,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

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
                                String val = opts.makeTooltip != null
                                    ? opts.makeTooltip!(spot.y)
                                    : spot.y.toStringAsFixed(3);
                                if (integer == true) {
                                  val = spot.y.toInt().toString();
                                }
                                return LineTooltipItem(
                                  '${spot.x.toInt()}  $val',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        minX: 1,
                        maxX: daysInMonth.toDouble(),
                        minY: 0,
                        maxY: null,
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
