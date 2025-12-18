import 'package:flutter/material.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/time_stats.dart';

class GridChart extends StatelessWidget {
  final DateTime firstDayOfMonth;
  final ChartOpts opts;

  const GridChart({
    super.key,
    required this.firstDayOfMonth,
    required this.opts,
  });

  List<Widget> _buildGridSquares(BuildContext context) {
    final defaultColor = detaTheme.colorScheme.tertiaryContainer;

    final int leadingBlanks = firstDayOfMonth.weekday - 1;
    final int daysInMonth = DateUtils.getDaysInMonth(
      firstDayOfMonth.year,
      firstDayOfMonth.month,
    );
    final List<Widget> squares = [];

    // add week days labels
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (final day in weekDays) {
      squares.add(
        Container(alignment: Alignment.center, child: Txt(w: 6, day)),
      );
    }

    for (int i = 0; i < leadingBlanks; i++) {
      squares.add(const SizedBox.shrink());
    }

    double maxVal = 0;

    for (int i = 0; i < daysInMonth; i++) {
      final date = firstDayOfMonth.add(Duration(days: i));
      final matches = opts.recordFts.where(
        (rf) =>
            strDate(rf['date'] as DateTime) == strDate(date) &&
            opts.getRecordValue(rf) > 0,
      );

      List<Color> colors = [];
      List<double> values = [];

      late Color dayColor;
      late double dayValue;

      if (matches.isEmpty) {
        dayColor = Colors.white.withAlpha(0);
        dayValue = 0;
      } else {
        if (opts.getDayColor?.call(matches.first) == null) {
          dayColor = defaultColor;
        } else {
          for (final m in matches) {
            final c = opts.getDayColor!(m);
            if (c != null) {
              colors.add(c);
            }
          }

          // most repeated color
          dayColor = colors.reduce(
            (a, b) =>
                colors.where((c) => c == a).length >=
                    colors.where((c) => c == b).length
                ? a
                : b,
          );
        }

        for (final m in matches) {
          final v = opts.getRecordValue(m);
          values.add(v);
        }
        //dayValue = values.reduce((a, b) => a + b) / values.length;
        dayValue = operate(
          // in case of mood ft or any other thats uses different colors:
          // get value only from the records of "same color"
          matches.where(
            (m) => opts.getDayColor?.call(m) == null
                ? true
                : dayColor == opts.getDayColor!(m),
          ),
          opts.operation,
          opts.getRecordValue,
        );

        if (dayValue > maxVal) maxVal = dayValue;
      }

      squares.add(
        Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          message: dayValue.toInt().toString(),
          child: Container(
            decoration: BoxDecoration(
              color: dayColor.withAlpha(
                //max value -> 255
                     dayValue == 0
                    ? 0
                    : (((dayValue / maxVal) * 155).toInt()) + 100,
              ),

              borderRadius: BorderRadius.circular(10.0),

              // if square date match today set border of primary color
              border: strDate(DateTime.now()) == strDate(date)
                  ? Border.all(color: seedColor, width: 4.0)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(5),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    int trailingBlanks = 42 - squares.length;
    if (trailingBlanks > 0) {
      for (int i = 0; i < trailingBlanks; i++) {
        squares.add(const SizedBox.shrink());
      }
    }

    return squares;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1.0,
        children: _buildGridSquares(context),
      ),
    );
  }
}
