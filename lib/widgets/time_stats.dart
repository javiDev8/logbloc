import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/dropdown.dart';
import 'package:logbloc/widgets/design/monthly_chart.dart';
import 'package:logbloc/widgets/design/weekly_chart.dart';
import 'package:logbloc/widgets/design/yearly_chart.dart';

class TimeStats extends StatelessWidget {
  final ChartOpts chartOpts;
  final Map<String, double Function(Map<String, dynamic>)> showOptions;

  const TimeStats({
    super.key,
    required this.chartOpts,
    required this.showOptions,
  });

  @override
  Widget build(BuildContext context) {
    String timeLapse = 'week';
    String mode = chartOpts.mode;

    return StatefulBuilder(
      builder: (context, setState) {
        chartOpts.mode = mode;
	if (mode == 'grid' && timeLapse == 'week') {
	  timeLapse = 'month';
	}

        return Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: ['dump', 'grid', 'chart']
                    .map<Widget>(
                      (p) => Button(
                        p,
                        variant: 0,
                        filled: p == mode,
                        onPressed: () => setState(() => mode = p),
                      ),
                    )
                    .toList(),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: ['year', 'month', 'week']
                    .map<Widget>(
                      (p) => Button(
                        disabled: mode == 'grid' && p == 'week',
                        p,
                        variant: 2,
                        filled: p == timeLapse,
                        onPressed: () => setState(() => timeLapse = p),
                      ),
                    )
                    .toList(),
              ),
            ),

            if (mode != 'dump')
              Padding(
                padding: EdgeInsetsGeometry.only(
                  top: 5,
                  left: 15,
                  right: 15,
                ),
                child: Row(
                  children: [
                    Dropdown(
                      label: Text('show'),
                      init: chartOpts.getRecordValue,
                      entries: showOptions.entries
                          .map(
                            (o) => DropdownMenuEntry(
                              value: o.value,
                              label: o.key,
                            ),
                          )
                          .toList(),
                      onSelect: (val) {
                        setState(() => chartOpts.getRecordValue = val);
                      },
                    ),
                  ],
                ),
              ),

            if (timeLapse == 'week')
              WeeklyChart(opts: chartOpts)
            else if (timeLapse == 'month')
              MonthlyChart(opts: chartOpts)
            else if (timeLapse == 'year')
              YearlyChart(opts: chartOpts),
          ],
        );
      },
    );
  }
}

enum ChartOperation { add, average, min, max }

double operate(
  Iterable<Map<String, dynamic>> dayFtRecs,
  ChartOperation operation,
  double Function(Map<String, dynamic>) getRecordValue,
) {
  if (dayFtRecs.isEmpty) return 0.0;
  switch (operation) {
    case ChartOperation.average:
      return dayFtRecs.fold<double>(
            0.0,
            (sum, rec) => sum + getRecordValue(rec),
          ) /
          dayFtRecs.length;

    case ChartOperation.min:
      return dayFtRecs
          .map<double>((rec) => getRecordValue(rec))
          .reduce((a, b) => a < b ? a : b);

    case ChartOperation.max:
      return dayFtRecs
          .map<double>((rec) => getRecordValue(rec))
          .reduce((a, b) => a > b ? a : b);

    case ChartOperation.add:
      return dayFtRecs.fold<double>(
        0.0,
        (sum, rec) => sum + getRecordValue(rec),
      );
  }
}

class ChartOpts {
  Feature ft;
  double Function(Map<String, dynamic>) getRecordValue;
  Color? Function(Map<String, dynamic>?)? getDayColor;

  List<Map<String, dynamic>> recordFts;
  String? unit;
  bool? integer;
  ChartOperation operation;
  final String Function(double)? makeTooltip;
  bool isFt;
  String mode;

  ChartOpts({
    required this.ft,
    required this.getRecordValue,
    required this.recordFts,
    required this.operation,
    this.unit,
    this.integer,
    this.makeTooltip,
    this.isFt = true,
    this.mode = 'chart',
    this.getDayColor,
  });
}
