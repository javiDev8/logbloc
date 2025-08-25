import 'package:logize/features/task_list/task_list_ft_class.dart';
import 'package:flutter/material.dart';
import 'package:logize/widgets/time_stats.dart';

class TaskListFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final TaskListFt ft;
  const TaskListFtStatsWidget({
    super.key,
    required this.ftRecs,
    required this.ft,
  });

  Iterable<Task> getRootTasks(Map<String, dynamic> ftRec) {
    final taskList = TaskListFt.fromEntry(
      MapEntry(ft.key, ft.serialize()),
      ftRec,
    );
    return taskList.tasks.values.where((t) => t.isRoot);
  }

  double getDoneRate(Map<String, dynamic> ftRec) {
    final rootTasks = getRootTasks(ftRec);
    return rootTasks.where((r) => r.done).length / rootTasks.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : Expanded(
                child: TimeStats(
                  chartOpts: ChartOpts(
                    chartLabel: 'Done tasks rate',
                    ft: ft,
                    operation: ChartOperation.average,
                    integer: true,
                    recordFts: ftRecs,

                    getRecordValue: (Map<String, dynamic> rec) =>
                        getDoneRate(rec),
                    unit: '%',
                  ),
                ),
              ),
      ],
    );
  }
}
