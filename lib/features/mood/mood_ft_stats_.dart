import 'package:logbloc/features/mood/mood_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class MoodFtStats extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final MoodFt ft;
  const MoodFtStats({super.key, required this.ftRecs, required this.ft});

  double getAll(r) => (r['intensity'] as int).toDouble();

  double Function(Map<String, dynamic>) makeMoodGet(String moodId) =>
      (rec) {
        if (rec['moodId'] == moodId) {
          return (rec['intensity'] as int).toDouble();
        } else {
          return 0;
        }
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : TimeStats(
                showOptions: {
                  'predominant mood': getAll,
                  'happy': makeMoodGet('happy'),
                  'angry': makeMoodGet('angry'),
                  'fear': makeMoodGet('fear'),
                  'surprise': makeMoodGet('surprise'),
                  'disgust': makeMoodGet('disgust'),
                  'sad': makeMoodGet('sad'),
                  'neutral': makeMoodGet('neutral'),
                },
                chartOpts: ChartOpts(
                  mode: 'grid',
                  operation: ChartOperation.average,
                  getDayColor: (r) => r == null
                      ? null
                      : (moods[r['moodId']]!['color'] as Color),
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
