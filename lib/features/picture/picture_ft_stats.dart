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

  @override
  Widget build(BuildContext context) {
    return TimeStats(
      showOptions: {},
      chartOpts: ChartOpts(
	mode: 'grid',
        operation: ChartOperation.add,
        ft: ft,
        getRecordValue: ((_) => 1),
        recordFts: ftRecs,
        integer: true,
      ),
    );
  }
}
