import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/features/feature_switch.dart';
import 'package:logbloc/features/task_list/task_list_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/widgets/time_stats.dart';

class TaskListFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final TaskListFt ft;
  const TaskListFtStatsWidget({
    super.key,
    required this.ftRecs,
    required this.ft,
  });

  Iterable<Task> getDayTask(Map<String, dynamic> ftRec) {
    final taskList = TaskListFt.fromEntry(
      MapEntry(ft.key, ft.serialize()),
      ftRec,
    );
    return taskList.tasks.values.where((t) => t.isRoot);
  }

  double getDoneRate(Map<String, dynamic> ftRec) {
    final Feature recFt = featureSwitch(
      ftType: ft.type,
      parseType: 'class',
      recordFt: ftRec,
      entry: MapEntry(ft.key, ft.serialize()),
    );
    return recFt.completeness * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : Expanded(
                child: TimeStats(
                  showOptions: {'complete rate (%)': getDoneRate},
                  chartOpts: ChartOpts(
                    operation: ChartOperation.average,
                    ft: ft,
                    integer: true,
                    recordFts: ftRecs,

                    getRecordValue: getDoneRate,
                    unit: '%',
                  ),
                ),
              ),
      ],
    );
  }
}
