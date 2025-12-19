import 'package:flutter/material.dart';
import 'package:logbloc/pools/records/record_class.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logbloc/widgets/design/dropdown.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/year_grid_chart.dart';
import 'package:logbloc/widgets/dump_ft_records.dart';
import 'package:logbloc/widgets/dump_records.dart';
import 'package:logbloc/widgets/time_stats.dart';

class YearlyChart extends StatelessWidget {
  final ChartOpts opts;
  final PageController pageController = PageController(initialPage: 1000);

  YearlyChart({super.key, required this.opts});

  int getDaysInYear(DateTime date) => DateTime(
    date.year + 1,
    1,
    1,
  ).difference(DateTime(date.year, 1, 1)).inDays;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final recordFts = opts.recordFts;
        final getRecordValue = opts.getRecordValue;
        final ChartOperation operation = opts.operation;
        final bool? integer = opts.integer;

        final dump = opts.mode == 'dump';

        final color =
            opts.getDayColor?.call({}) ??
            detaTheme.colorScheme.tertiaryContainer;

        return SizedBox(
          height: 430,
          child: PageView.builder(
            controller: pageController,
            itemBuilder: (context, index) {
              final now = DateTime.now();
              final targetYear = DateTime(
                now.year + (index - pageController.initialPage),
                1,
                1,
              );
              final firstDayOfYear = targetYear;

              bool manyPerDay = false;

              final yearData = List.generate(12, (monthIndex) {
                final month = monthIndex + 1;
                final monthRecs = recordFts.where((rec) {
                  final recDate = rec['date'] as DateTime;
                  return recDate.year == targetYear.year &&
                      recDate.month == month;
                });
                if (monthRecs.isEmpty) return null;

                if (monthRecs.length > 1) manyPerDay = true;

                return operate(monthRecs, operation, getRecordValue);
              });

              final n = DateTime.now();
              final yearColor = firstDayOfYear.year == n.year
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
                            label: Text('operation on each month'),
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
                            firstDayOfYear.year.toString(),
                            color: yearColor,
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
                                                targetYear.year,
                                          )
                                          .toList(),
                                    )
                                    .map(
                                      (w) =>
                                          Row(children: [Expanded(child: w)]),
                                    )
                                    .toList()
                              : dumpRecrods(
                                  recordFts
                                      .where(
                                        (rec) =>
                                            rec['date'].year == targetYear.year,
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
                                        color: color,
                                      ),
                                ),
                                spots: List.generate(12, (index) {
                                  final spot = yearData[index];
                                  if (spot == null) {
                                    return FlSpot.nullSpot;
                                  }
                                  return FlSpot(
                                    (index + 1).toDouble(),
                                    yearData[index]!,
                                  );
                                }),
                                color: color,
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
                                    final month = value.toInt();
                                    final bool isCurrentMonth =
                                        targetYear.year == now.year &&
                                        month == now.month;

                                    if (month < 1 || month > 12) {
                                      return const SizedBox.shrink();
                                    }

                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 8.0,
                                      child: Text(
                                        months[month],
                                        style: TextStyle(
                                          color: isCurrentMonth
                                              ? seedColor
                                              : null,
                                          fontWeight: isCurrentMonth
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
                                      '${months[spot.x.toInt()]}  $val',
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            minX: 1,
                            maxX: 12,
                            minY: 0,
                            maxY: null,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 300,
                        child: YearGridChart(
                          firstDayOfYear: firstDayOfYear,
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
