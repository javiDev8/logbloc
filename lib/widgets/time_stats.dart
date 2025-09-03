import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/daily_chart.dart';
import 'package:logbloc/widgets/design/dropdown.dart';
import 'package:logbloc/widgets/design/monthly_chart.dart';
import 'package:logbloc/widgets/design/weekly_chart.dart';

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
    String mode = 'chart';
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: ['month', 'week', 'day']
                  .map<Widget>(
                    (p) => Button(
                      p,
                      variant: 2,
                      filled: p == timeLapse,
                      onPressed: () => setState(() => timeLapse = p),
                    ),
                  )
                  .toList(),
            ),
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: ['dump', 'chart']
                  .map<Widget>(
                    (p) => Button(
                      p,
                      variant: 1,
                      filled: p == mode,
                      onPressed: () => setState(() => mode = p),
                    ),
                  )
                  .toList(),
            ),
          ),

          if (mode == 'chart')
            Padding(
              padding: EdgeInsetsGeometry.only(
                top: 5,
                left: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  Dropdown(
                    label: Text('show'),
                    init: chartOpts.operation,
                    onSelect: (val) =>
                        setState(() => chartOpts.operation = val),
                    entries: [
                      DropdownMenuEntry(
                        value: ChartOperation.add,
                        label: 'total',
                      ),
                      DropdownMenuEntry(
                        value: ChartOperation.average,
                        label: 'average',
                      ),
                    ],
                  ),

                  Dropdown(
                    label: Text('unit'),
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

          if (timeLapse == 'day')
            DailyChart(opts: chartOpts, dump: mode == 'dump'),
          if (timeLapse == 'week')
            WeeklyChart(opts: chartOpts, dump: mode == 'dump')
          else if (timeLapse == 'month')
            MonthlyChart(opts: chartOpts, dump: mode == 'dump'),
        ],
      ),
    );
  }
}

enum ChartOperation { add, average }

class ChartOpts {
  Feature ft;
  double Function(Map<String, dynamic>) getRecordValue;
  List<Map<String, dynamic>> recordFts;
  String? unit;
  bool? integer;
  ChartOperation operation;
  final String Function(double)? makeTooltip;

  ChartOpts({
    required this.ft,
    required this.getRecordValue,
    required this.recordFts,
    required this.operation,
    this.unit,
    this.integer,
    this.makeTooltip,
  });
}
