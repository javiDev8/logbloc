import 'package:flutter/material.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/widgets/time_stats.dart';

class YearGridChart extends StatelessWidget {
  final DateTime firstDayOfYear;
  final ChartOpts opts;

  const YearGridChart({
    super.key,
    required this.firstDayOfYear,
    required this.opts,
  });

  int getDaysInYear(DateTime date) => DateTime(
    date.year + 1,
    1,
    1,
  ).difference(DateTime(date.year, 1, 1)).inDays;

  @override
  Widget build(BuildContext context) {
    final defaultColor = detaTheme.colorScheme.tertiaryContainer;

    double maxVal = 0;

    // First pass to find maxVal
    for (int i = 0; i < 365; i++) {
      final date = firstDayOfYear.add(Duration(days: i));
      final matches = opts.recordFts.where(
        (rf) => strDate(rf['date'] as DateTime) == strDate(date),
      );
      if (matches.isNotEmpty) {
        final value = operate(
          matches,
          ChartOperation.average,
          opts.getRecordValue,
        );
        if (value > maxVal) maxVal = value;
      }
    }

    final List<Widget> monthWidgets = [];
    for (int m = 1; m <= 12; m++) {
      final daysInMonth = DateUtils.getDaysInMonth(firstDayOfYear.year, m);
      final List<Widget> monthSquares = [];
      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(firstDayOfYear.year, m, d);
        final matches = opts.recordFts.where(
          (rf) => strDate(rf['date'] as DateTime) == strDate(date),
        );

        double dayValue = 0;
        Color dayColor = defaultColor;
        if (matches.isNotEmpty) {
          dayValue = operate(
            matches,
            ChartOperation.average,
            opts.getRecordValue,
          );
          if (opts.getDayColor != null) {
            final colors = matches
                .map((m) => opts.getDayColor!(m))
                .where((c) => c != null)
                .toList();
            if (colors.isNotEmpty) {
              // most repeated color
              dayColor = colors.reduce(
                (a, b) =>
                    colors.where((c) => c == a).length >=
                        colors.where((c) => c == b).length
                    ? a
                    : b,
              )!;
            }
          }
        }

        monthSquares.add(
          ClipOval(
            child: Container(
              decoration: BoxDecoration(
                color: dayColor.withAlpha(
                  maxVal == 0
                      ? 0
                      : dayValue == 0
                      ? 0
                      : (((dayValue / maxVal) * 155).toInt()) + 100,
                ),
                border: strDate(DateTime.now()) == strDate(date)
                    ? Border.all(color: seedColor, width: 1.0)
                    : null,
              ),
            ),
          ),
        );
      }
      // Fill to 35 squares (5x7)
      for (int i = daysInMonth; i < 35; i++) {
        monthSquares.add(const SizedBox.shrink());
      }

      monthWidgets.add(
        Container(
          padding: const EdgeInsets.all(2.0),
          child: GridView.count(
            crossAxisCount: 5,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: monthSquares,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: monthWidgets,
      ),
    );
  }
}
