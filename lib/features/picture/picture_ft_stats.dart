import 'package:flutter/material.dart';
import 'package:logbloc/features/picture/picture_ft_class.dart';
import 'package:logbloc/widgets/time_stats.dart';

class PictureFtStats extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final PictureFt ft;
  const PictureFtStats({
    super.key,
    required this.ft,
    required this.ftRecs,
  });

  double getAll(_) => 1;

  @override
  Widget build(BuildContext context) {
    return TimeStats(
      showOptions: {'all': getAll},
      chartOpts: ChartOpts(
        mode: 'dump',
        operation: ChartOperation.add,
        ft: ft,
        getRecordValue: getAll,
        recordFts: ftRecs,
        integer: true,
      ),
    );
  }
}
