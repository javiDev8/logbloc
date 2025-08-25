import 'package:flutter/material.dart';
import 'package:logize/features/feature_class.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/daily_chart.dart';
import 'package:logize/widgets/design/monthly_chart.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/weekly_chart.dart';

class TimeStats extends StatelessWidget {
  final ChartOpts chartOpts;
  const TimeStats({super.key, required this.chartOpts});

  @override
  Widget build(BuildContext context) {
    String showing = 'week';
    return StatefulBuilder(
      builder: (context, setState) => ListView(
        children: [
          if (showing == 'day') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Txt('Raw content', w: 7, s: 17)],
            ),
            DailyChart(chartOpts: chartOpts),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Txt(chartOpts.chartLabel, w: 7, s: 17)],
            ),
          if (showing == 'week')
            WeeklyChart(opts: chartOpts)
          else if (showing == 'month')
            MonthlyChart(opts: chartOpts),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: ['month', 'week', 'day']
                  .map<Widget>(
                    (p) => Button(
                      p,
                      variant: 2,
                      filled: p == showing,
                      onPressed: () => setState(() => showing = p),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

enum ChartOperation { add, average }

class ChartOpts {
  String chartLabel;
  Feature ft;
  double Function(Map<String, dynamic>) getRecordValue;
  List<Map<String, dynamic>> recordFts;
  String? unit;
  ChartOperation operation;
  bool? integer;

  ChartOpts({
    required this.chartLabel,
    required this.ft,
    required this.getRecordValue,
    required this.recordFts,
    required this.operation,
    this.unit,
    this.integer,
  });
}
