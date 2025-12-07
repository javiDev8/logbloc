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

  @override
  Widget build(BuildContext context) {
    double getElapsedTime(Map<String, dynamic> rec) {
      return rec['elapsedTime']?.toDouble() ?? 0.0;
    }

    bool getIsRunning(Map<String, dynamic> rec) {
      return rec['isRunning'] ?? false;
    }

    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : TimeStats(
                showOptions: {
                  'elapsed time (secs)': getElapsedTime,
                  'was running': (rec) => getIsRunning(rec) ? 1.0 : 0.0,
                },
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
