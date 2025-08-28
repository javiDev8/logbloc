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
    double getChars(Map<String, dynamic> rec) {
      return rec['content']?.length.toDouble() ?? 0.0;
    }

    double getWords(Map<String, dynamic> rec) {
      return rec['content']?.split(' ').length.toDouble() ?? 0.0;
    }

    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : TimeStats(
                showOptions: {'characters': getChars, 'words': getWords},
                chartOpts: ChartOpts(
                  operation: ChartOperation.add,
                  ft: ft,
                  integer: true,
                  recordFts: ftRecs,
                  getRecordValue: getChars,
                  unit: 'characters',
                ),
              ),
      ],
    );
  }
}
