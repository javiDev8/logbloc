import 'package:flutter/material.dart';
import 'package:logize/features/picture/picture_ft_class.dart';
import 'package:logize/widgets/time_stats.dart';

class PictureFtStats extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final PictureFt ft;
  const PictureFtStats({
    super.key,
    required this.ft,
    required this.ftRecs,
  });

  @override
  Widget build(BuildContext context) {
    return TimeStats(
      chartOpts: ChartOpts(
        ft: ft,
        getRecordValue: ((_) => 1),
        recordFts: ftRecs,
        operation: ChartOperation.add,
        integer: true,
      ),
    );
  }
}
