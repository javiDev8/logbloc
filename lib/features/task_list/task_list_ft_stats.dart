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

  double getDone(Map<String, dynamic> ftRec) {
    final rootTasks = getRootTasks(ftRec);
    return rootTasks.where((r) => r.done).length.toDouble();
  }

  double getPending(Map<String, dynamic> ftRec) {
    final rootTasks = getRootTasks(ftRec);
    return rootTasks.where((r) => !r.done).length.toDouble();
  }

  double getTasks(Map<String, dynamic> ftRec) {
    final rootTasks = getRootTasks(ftRec);
    return rootTasks.length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : Expanded(
                child: TimeStats(
                  showOptions: {
                    'tasks': getTasks,
                    'done tasks': getDone,
                    'pending tasks': getPending,
                    'done %': getDoneRate,
                  },
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
