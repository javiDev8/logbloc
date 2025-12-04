import 'package:logbloc/features/timer/timer_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class TimerFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final TimerFt ft;
  const TimerFtStatsWidget({super.key, required this.ftRecs, required this.ft});

  @override
  Widget build(BuildContext context) {
    double getPassedTime(Map<String, dynamic> rec) {
      return rec['passedTime']?.toDouble() ?? 0.0;
    }

    double getDuration(Map<String, dynamic> rec) {
      return rec['duration']?.toDouble() ?? 0.0;
    }

    double getCompleteness(Map<String, dynamic> rec) {
      final passed = rec['passedTime'] as int? ?? 0;
      final duration = rec['duration'] as int? ?? 1;
      return duration > 0
          ? (passed >= duration ? 1.0 : passed / duration)
          : 0.0;
    }

    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : TimeStats(
                showOptions: {
                  'passed time (seconds)': getPassedTime,
                  'duration (seconds)': getDuration,
                  'completeness': getCompleteness,
                },
                chartOpts: ChartOpts(
                  operation: ChartOperation.add,
                  ft: ft,
                  integer: false,
                  recordFts: ftRecs,
                  getRecordValue: getPassedTime,
                  unit: 'seconds',
                ),
              ),
      ],
    );
  }
}
