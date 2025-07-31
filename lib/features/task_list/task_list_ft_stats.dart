import 'package:logize/features/task_list/task_list_ft_class.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/weekly_chart.dart';
import 'package:flutter/material.dart';

class TaskListFtStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final TaskListFt ft;
  const TaskListFtStatsWidget({
    super.key,
    required this.ftRecs,
    required this.ft,
  });

  Task getRootTask(Map<String, dynamic> ftRec) {
    final taskList = TaskListFt.fromEntry(
      MapEntry(ft.key, ft.serialize()),
      ftRec,
    );
    return taskList.tasks.values.firstWhere((t) => t.isRoot);
  }

  double getDoneRate(Map<String, dynamic> ftRec) {
    final rootTask = getRootTask(ftRec);
    return rootTask.doneSubTasks / rootTask.childrenIds.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    final rootTask = getRootTask(ftRecs[0]);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: SectionDivider(
            string: '"${rootTask.title}" done tasks rate',
          ),
        ),
        ftRecs.isEmpty
            ? Center(child: Text('no records'))
            : WeeklyChart(
              integer: true,
              recordFts: ftRecs,

              getRecordValue:
                  (Map<String, dynamic> rec) => getDoneRate(rec),
              unit: '%',
            ),
      ],
    );
  }
}
