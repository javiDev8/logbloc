import 'package:flutter/material.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/screens/models/model_screen/feature_stats_screen.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/dropdown.dart';
import 'package:logbloc/widgets/design/monthly_chart.dart';
import 'package:logbloc/widgets/design/section_divider.dart';
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
    String mode = chartOpts.mode;

    return StatefulBuilder(
      builder: (context, setState) {
        chartOpts.mode = mode;
        if (mode == 'grid') timeLapse = 'month';
        return SingleChildScrollView(
          child: Column(
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
                  children: ['month', 'week']
                      .map<Widget>(
                        (p) => Button(
                          disabled: mode == 'grid',
                          p,
                          variant: 2,
                          filled: p == timeLapse,
                          onPressed: () => setState(() => timeLapse = p),
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
                      //Dropdown(
                      //  label: Text('show'),
                      //  init: chartOpts.operation,
                      //  onSelect: (val) =>
                      //      setState(() => chartOpts.operation = val),
                      //  entries: [
                      //    DropdownMenuEntry(
                      //      value: ChartOperation.add,
                      //      label: 'total',
                      //    ),
                      //    DropdownMenuEntry(
                      //      value: ChartOperation.average,
                      //      label: 'average',
                      //    ),
                      //    DropdownMenuEntry(
                      //      value: ChartOperation.min,
                      //      label: 'min',
                      //    ),
                      //    DropdownMenuEntry(
                      //      value: ChartOperation.max,
                      //      label: 'max',
                      //    ),
                      //  ],
                      //),
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

              if (timeLapse == 'week')
                WeeklyChart(opts: chartOpts)
              else if (timeLapse == 'month')
                MonthlyChart(opts: chartOpts),

              if (!chartOpts.isFt) ...[
                SectionDivider(string: 'Feature records'),
                ...modelEditPool.data.features.values.map(
                  (ft) => ListTile(
                    onTap: () =>
                        navPush(screen: FeatureStatsScreen(ftKey: ft.key)),
                    title: Text(ft.title),
                    leading: Icon(
                      featureSwitch(parseType: 'icon', ftType: ft.type),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
