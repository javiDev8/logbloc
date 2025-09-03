import 'package:flutter/material.dart';
import 'package:logbloc/features/chronometer/chronometer_ft_class.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/time_stats.dart';

class ChronometerFtStats extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final ChronometerFt ft;
  const ChronometerFtStats({
    super.key,
    required this.ftRecs,
    required this.ft,
  });

  @override
  Widget build(BuildContext context) {
    double getMillisecs(Map<String, dynamic> rec) {
      return (rec['duration'] as int).toDouble();
    }

    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Txt('no records'))
            : TimeStats(
                showOptions: {'duration': getMillisecs},
                chartOpts: ChartOpts(
                  makeTooltip: (val) =>
                      fmtDuration(Duration(milliseconds: val.toInt())),
                  operation: ChartOperation.add,
                  ft: ft,
                  integer: true,
                  recordFts: ftRecs,
                  getRecordValue: getMillisecs,
                  unit: 'seconds',
                ),
              ),
      ],
    );
  }
}
