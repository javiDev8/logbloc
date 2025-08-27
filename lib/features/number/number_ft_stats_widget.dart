import 'package:logbloc/features/number/number_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

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
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : Expanded(
                child: TimeStats(
                  chartOpts: ChartOpts(
                    chartLabel: 'Total ${ft.title}',
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
