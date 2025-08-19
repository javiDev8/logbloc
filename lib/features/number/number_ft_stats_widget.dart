import 'package:logize/features/number/number_ft_class.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:logize/widgets/time_stats.dart';

class NumberFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final NumberFt ft;
  const NumberFtStatsWidget({
    super.key,
    required this.ftRecs,
    required this.ft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: SectionDivider(string: '"${ft.title}" (${ft.unit})'),
        ),
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : Expanded(
                child: TimeStats(
                  chartOpts: ChartOpts(
		    ft: ft,
                    operation: ChartOperation.add,
                    recordFts: ftRecs,
                    getRecordValue: (Map<String, dynamic> rec) {
                      return rec['value']?.toDouble() ?? 0.0;
                    },
                    unit: ft.unit,
                  ),
                ),
              ),
      ],
    );
  }
}
