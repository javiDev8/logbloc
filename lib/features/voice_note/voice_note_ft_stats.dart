import 'package:flutter/material.dart';
import 'package:logbloc/features/voice_note/voice_note_ft_class.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/time_stats.dart';

class VoiceNoteFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final VoiceNoteFt ft;
  const VoiceNoteFtStatsWidget({
    super.key,
    required this.ftRecs,
    required this.ft,
  });
  double getSeconds(Map<String, dynamic> rec) {
    return (rec['duration'] ?? 0) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Txt('no records'))
            : TimeStats(
                showOptions: {'duration (seconds)': getSeconds},
                chartOpts: ChartOpts(
                  mode: 'dump',
                  operation: ChartOperation.add,
                  ft: ft,
                  integer: true,
                  recordFts: ftRecs,
                  getRecordValue: getSeconds,
                  unit: 'seconds',
                ),
              ),
      ],
    );
  }
}
