import 'package:logbloc/features/mood/mood_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class MoodFtStats extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final MoodFt ft;
  const MoodFtStats({super.key, required this.ftRecs, required this.ft});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : TimeStats(
                showOptions: {'all': (r) => 1},
                chartOpts: ChartOpts(
                  operation: ChartOperation.add,
                  ft: ft,
                  integer: true,
                  recordFts: ftRecs,
                  getRecordValue: (r) => 1,
                  unit: 'characters',
                ),
              ),
      ],
    );
  }
}
