import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/edit/actions/add_sch_rule_button.dart';
import 'package:logize/widgets/design/section_divider.dart';

class ScheduleWidget extends StatelessWidget {
  final Model model;
  final Schedule schedule;
  final bool locked;
  const ScheduleWidget({
    super.key,
    required this.schedule,
    required this.locked,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Column(
        children: [
          Text('period: ${schedule.period ?? 'puntual'}'),
          Text('day: ${schedule.day}'),

          ...model.features.values.map<Widget>(
            (ft) => Row(
              children: [
                Checkbox(
                  value: schedule.includedFts?.contains(ft.key) == true,
                  onChanged: (val) {
                    if (val == true &&
                        schedule.includedFts?.contains(ft.key) != true) {
                      schedule.includedFts ??= [];
                      schedule.includedFts!.add(ft.key);
                    } else if (val == false &&
                        schedule.includedFts?.contains(ft.key) == true) {
                      schedule.includedFts!.removeWhere(
                        (ftKey) => ftKey == ft.key,
                      );
                    }
                    modelEditPool.controller.sink.add('schedules');
                  },
                ),
                Text(ft.key),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SchedulesView extends StatelessWidget {
  final Model model;
  final bool locked; // describes if editing
  const SchedulesView({
    super.key,
    required this.model,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LazySwimmer<Model>(
        pool: modelEditPool,
        listenedEvents: locked ? [] : ['schedules'],
        builder: (context, editingModel) => ListView(
          children: [
            SectionDivider(string: 'Schedules', lead: AddSchRuleButton()),

            ...((locked
                        ? model.schedules
                        : editingModel.schedules ?? []) ??
                    [])
                .map(
                  (sch) => ScheduleWidget(
                    schedule: sch,
                    locked: locked,
                    model: model,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
