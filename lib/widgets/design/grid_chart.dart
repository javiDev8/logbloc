import 'package:flutter/material.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/widgets/design/none.dart';
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
    final int leadingBlanks = firstDayOfMonth.weekday - 1;
    final int daysInMonth = DateUtils.getDaysInMonth(
      firstDayOfMonth.year,
      firstDayOfMonth.month,
    );
    final List<Widget> squares = [];

    for (int i = 0; i < leadingBlanks; i++) {
      squares.add(const SizedBox.shrink());
    }

    for (int i = 0; i < daysInMonth; i++) {
      final date = firstDayOfMonth.add(Duration(days: i));
      final matches = opts.recordFts.where(
        (rf) => strDate(rf['date'] as DateTime) == strDate(date),
      );

      //final val = operate(matches, opts.operation, opts.getRecordValue);

      late Color dayColor;
      if (matches.isEmpty) {
        dayColor = Colors.white.withAlpha(0);
      } else {
        dayColor = Theme.of(context).colorScheme.tertiaryContainer;
      }

      squares.add(
        Container(
          decoration: BoxDecoration(
            color: dayColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          alignment: Alignment.center,
          child: None(),
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
