import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/dump_ft_records.dart';
import 'package:logbloc/widgets/time_stats.dart';

class DailyChart extends StatelessWidget {
  final ChartOpts opts;
  final bool dump;
  final PageController pageController = PageController(initialPage: 1000);

  DailyChart({super.key, required this.opts, required this.dump});

  // A new helper function to get the start of the day (midnight).
  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Helper function to format the hour for the chart's x-axis labels.
  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final recordFts = opts.recordFts;
    final getRecordValue = opts.getRecordValue;
    final ChartOperation operation = opts.operation;
    final bool? integer = opts.integer;

    return SizedBox(
      height: dump ? 500 : 400,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {},
        itemBuilder: (context, index) {
          final now = DateTime.now();
          // Calculate the target day instead of the target Monday.
          final targetDay = _getStartOfDay(
            now,
          ).add(Duration(days: (index - pageController.initialPage)));

          // Now, generate data for 24 hours of the day.
          final dayData = List.generate(24, (hourIndex) {
            final hourFtRecs = recordFts.where((rec) {
              final ts = rec['time'].split(':');
              final recDate = (rec['date'] as DateTime).copyWith(
                hour: int.parse(ts[0]),
                minute: int.parse(ts[1]),
              );

              final targetHour = targetDay.add(Duration(hours: hourIndex));
              // Filter records that fall within the specific hour.
              // The isAfter is inclusive, and isBefore is exclusive.
              return (recDate.isAfter(targetHour) ||
                      recDate.isAtSameMomentAs(targetHour)) &&
                  recDate.isBefore(targetHour.add(Duration(hours: 1)));
            });
            switch (operation) {
              case ChartOperation.average:
                if (hourFtRecs.isEmpty) return 0.0;
                return hourFtRecs.fold<double>(
                      0.0,
                      (sum, rec) => sum + getRecordValue(rec),
                    ) /
                    hourFtRecs.length;
              default:
                return hourFtRecs.fold(
                  0.0,
                  (sum, rec) => sum + getRecordValue(rec),
                );
            }
          });

          final n = DateTime.now();
          final dayColor =
              targetDay.day == n.day &&
                  targetDay.month == n.month &&
                  targetDay.year == n.year
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
                        // Display the full date instead of month/year.
                        '${months[targetDay.month]} ${targetDay.day}, ${targetDay.year}',
                        style: TextStyle(
                          color: dayColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                if (dump) ...[
                  // Update the date range display to show the current day.
                  Expanded(
                    child: ListView(
                      children:
                          dumpFtRecords(
                                ft: opts.ft,
                                recordFts: recordFts
                                    .where(
                                      (ft) =>
                                          ft['date'].isAfter(
                                            targetDay.subtract(
                                              const Duration(hours: 1),
                                            ),
                                          ) &&
                                          ft['date'].isBefore(
                                            targetDay.add(
                                              const Duration(days: 1),
                                            ),
                                          ),
                                    )
                                    .toList(),
                              )
                              .map(
                                (w) => Row(children: [Expanded(child: w)]),
                              )
                              .toList(),
                    ),
                  ),
                ] else
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        // Bar groups now correspond to 24 hours.
                        barGroups: List.generate(24, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: dayData[i],
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiaryContainer,
                                width: 5, // Reduced width for more bars.
                                borderRadius: BorderRadius.circular(5),
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
                              // Use `_formatHour` for the bottom titles.
                              getTitlesWidget: (value, meta) {
                                final hourIndex = value.toInt();
                                if (hourIndex % 3 == 0) {
                                  // Show labels every 3 hours to avoid clutter.
                                  return SideTitleWidget(
                                    space: 4,
                                    meta: meta,
                                    child: Text(_formatHour(hourIndex)),
                                  );
                                }
                                return const SizedBox.shrink();
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
                                  String val = opts.makeTooltip != null
                                      ? opts.makeTooltip!(rod.toY)
                                      : rod.toY.toStringAsFixed(3);
                                  if (integer != null && integer) {
                                    val = val.split('.')[0];
                                  }
                                  final hour = group.x;
                                  return BarTooltipItem(
                                    // Include the formatted hour in the tooltip.
                                    '$val at ${_formatHour(hour)}',
                                    const TextStyle(color: Colors.white),
                                  );
                                },
                          ),
                        ),
                        alignment: BarChartAlignment.spaceAround,
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
