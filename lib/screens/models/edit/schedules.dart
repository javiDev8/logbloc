import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/edit/actions/add_sch_rule_button.dart';
import 'package:logize/screens/models/model_screen/model_schedules_view.dart';
import 'package:logize/widgets/design/section_divider.dart';


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
