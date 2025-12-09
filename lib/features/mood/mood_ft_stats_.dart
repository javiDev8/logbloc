import 'package:logbloc/features/mood/mood_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class MoodFtStats extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final MoodFt ft;
  const MoodFtStats({super.key, required this.ftRecs, required this.ft});

  double getAll(_) => 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : TimeStats(
                showOptions: {'all': getAll},
                chartOpts: ChartOpts(
                  mode: 'grid',
                  operation: ChartOperation.add,
                  getDayColor: (r) => r == null
                      ? null
                      : (moods[r['moodId']]!['color'] as Color).withAlpha(
                          ((r['intensity'] as int).toDouble() * 12.55 +
                                  125.5)
                              .toInt(),
                        ),
                  ft: ft,
                  integer: true,
                  recordFts: ftRecs,
                  getRecordValue: getAll,
                  unit: 'characters',
                ),
              ),
      ],
    );
  }
}
