import 'package:logbloc/features/text/text_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class TextFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final TextFt ft;
  const TextFtStatsWidget({
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
                    chartLabel: "Total characters",
                    ft: ft,
                    operation: ChartOperation.add,
                    integer: true,
                    recordFts: ftRecs,
                    getRecordValue: (Map<String, dynamic> rec) {
                      return rec['content']?.length.toDouble() ?? 0.0;
                    },
                    unit: 'characters',
                  ),
                ),
              ),
      ],
    );
  }
}
