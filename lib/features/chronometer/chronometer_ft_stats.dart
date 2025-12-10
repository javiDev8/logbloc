import 'package:logbloc/features/chronometer/chronometer_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class ChronometerFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final ChronometerFt ft;
  const ChronometerFtStatsWidget({
    super.key,
    required this.ftRecs,
    required this.ft,
  });
  double getElapsedTime(Map<String, dynamic> rec) {
    return rec['elapsedTime']?.toDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : TimeStats(
                showOptions: {'elapsed time (seconds)': getElapsedTime},
                chartOpts: ChartOpts(
                  operation: ChartOperation.average,
                  ft: ft,
                  integer: true,
                  recordFts: ftRecs,
                  getRecordValue: getElapsedTime,
                  unit: 'seconds',
                ),
              ),
      ],
    );
  }
}
