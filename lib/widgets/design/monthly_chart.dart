import 'package:flutter/material.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logbloc/widgets/design/dropdown.dart';
import 'package:logbloc/widgets/design/grid_chart.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/dump_ft_records.dart';
import 'package:logbloc/widgets/dump_records.dart';
import 'package:logbloc/widgets/time_stats.dart';

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
    return StatefulBuilder(
      builder: (context, setState) {
        final recordFts = opts.recordFts;
        final getRecordValue = opts.getRecordValue;
        final ChartOperation operation = opts.operation;
        final bool? integer = opts.integer;

        final dump = opts.mode == 'dump';

        final defaultColor = Theme.of(
          context,
        ).colorScheme.tertiaryContainer;

        return SizedBox(
          height: 430,
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

              bool manyPerDay = false;

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
                if (dayFtRecs.isEmpty) return null;

                if (dayFtRecs.length > 1) manyPerDay = true;

                return operate(dayFtRecs, operation, getRecordValue);
              });

              final n = DateTime.now();
              final monthColor =
                  firstDayOfMonth.month == n.month &&
                      firstDayOfMonth.year == n.year
                  ? seedColor
                  : null;

              return Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 15,
                  right: 15,
                  bottom: 10,
                ),
                child: Column(
                  children: [
                    if (manyPerDay && opts.mode != 'dump')
                      Row(
                        children: [
                          Dropdown(
                            label: Text('operation on each day'),
                            init: opts.operation,
                            onSelect: (val) =>
                                setState(() => opts.operation = val),
                            entries: [
                              DropdownMenuEntry(
                                value: ChartOperation.add,
                                label: 'total',
                              ),
                              DropdownMenuEntry(
                                value: ChartOperation.average,
                                label: 'average',
                              ),
                              DropdownMenuEntry(
                                value: ChartOperation.min,
                                label: 'min',
                              ),
                              DropdownMenuEntry(
                                value: ChartOperation.max,
                                label: 'max',
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      SizedBox(height: 58),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Txt(
                            '${months[firstDayOfMonth.month]}  '
                            '${firstDayOfMonth.year.toString()}',
                            color: monthColor,
                            s: 15,
                            w: 8,
                          ),
                        ],
                      ),
                    ),

                    if (dump)
                      Expanded(
                        child: ListView(
                          children: opts.isFt
                              ? dumpFtRecords(
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
                                      (w) => Row(
                                        children: [Expanded(child: w)],
                                      ),
                                    )
                                    .toList()
                              : dumpRecrods(
                                  recordFts
                                      .where(
                                        (rec) =>
                                            rec['date'].year ==
                                                targetMonth.year &&
                                            rec['date'].month ==
                                                targetMonth.month,
                                      )
                                      .map((sr) => Rec.fromMap(sr))
                                      .toList(),
                                ),
                        ),
                      )
                    else if (opts.mode == 'chart')
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                dotData: FlDotData(
                                  getDotPainter: (_, _, _, _) =>
                                      FlDotCirclePainter(
                                        radius: 5,
                                        color: defaultColor,
                                      ),
                                ),
                                spots: List.generate(daysInMonth, (index) {
                                  final spot = monthData[index];
                                  if (spot == null) {
                                    return FlSpot.nullSpot;
                                  }
                                  return FlSpot(
                                    (index + 1).toDouble(),
                                    monthData[index]!,
                                  );
                                }),
                                color: defaultColor,
                                barWidth: 3,
                                isStrokeCapRound: true,
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
                                              ? seedColor
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
                      )
                    else
                      SizedBox(
                        height: 300,
                        child: GridChart(
                          firstDayOfMonth: firstDayOfMonth,
                          opts: opts,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
