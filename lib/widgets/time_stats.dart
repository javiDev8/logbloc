import 'package:flutter/material.dart';
import 'package:logize/features/feature_class.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/daily_chart.dart';
import 'package:logize/widgets/design/monthly_chart.dart';
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
          if (showing == 'day')
            DailyChart(chartOpts: chartOpts)
          else if (showing == 'week')
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

          //Padding(
          //  padding: EdgeInsetsGeometry.all(15),
          //  child: Row(
          //    children: [
          //      Dropdown(
          //        label: Text('show'),
          //        entries: [],
          //        onSelect: (val) {},
          //      ),
          //      Dropdown(
          //        label: Text('operation'),
          //        entries: [],
          //        onSelect: (val) {},
          //      ),
          //    ],
          //  ),
          //),
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
  ChartOperation operation;
  bool? integer;

  ChartOpts({
    required this.ft,
    required this.getRecordValue,
    required this.recordFts,
    required this.operation,
    this.unit,
    this.integer,
  });
}
