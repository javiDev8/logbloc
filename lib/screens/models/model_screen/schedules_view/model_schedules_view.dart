import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_screen/schedules_view/add_schedule_button.dart';
import 'package:logize/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/period_picker_menu_button.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/section_divider.dart';

class ModelSchedulesView extends StatelessWidget {
  const ModelSchedulesView({super.key});

  @override
  Widget build(BuildContext context) {
    String showing = 'all';
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
      child: LazySwimmer<Model>(
        pool: modelEditPool,
        listenedEvents: ['schedules'],
        builder: (context, model) {
          final Map<String, List<Schedule>?> deserialSchs =
              Map.fromEntries(
                Schedule.periods.map(
                  (period) => MapEntry<String, List<Schedule>?>(
                    period ?? 'null',
                    model.schedules?.values
                        .where((sch) => sch.period == period)
                        .toList(),
                  ),
                ),
              );

          return StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.only(top: 15, bottom: 5),
                  child: Row(
                    children: [
                      ...['periodic', 'puntual', 'all'].map(
                        (t) => Button(
                          t,
                          variant: 2,
                          onPressed: () => setState(() => showing = t),
                          filled: showing == t,
                        ),
                      ),
                      Exp(),
                      AddScheduleButton(
                        type: showing,
                        deserialSchs: deserialSchs,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if (showing == 'all' || showing == 'periodic')
                        ...periodPickers.entries.expand<Widget>((ppe) {
                          if (model.simplePeriods?.contains(ppe.key) ==
                              true) {
                            return [
                              ppe.value.simplePicker(
                                deserialSchs[ppe.key],
                              ),
                            ];
                          } else if (deserialSchs[ppe.key]?.isNotEmpty ==
                              true) {
                            return [
                              SectionDivider(
                                string: ppe.key,
                                lead: PeriodPickerMenuButton(
                                  period: ppe.key,
                                ),
                              ),
                              ...deserialSchs[ppe.key]!.map(
                                (sch) => ScheduleWidget(
                                  schedule: sch,
                                  locked: true,
                                ),
                              ),

                              SizedBox(height: 20),
                            ];
                          } else {
                            return [];
                          }
                        }),

                      if ((showing == 'all' || showing == 'puntual') &&
                          deserialSchs['null']?.isNotEmpty == true) ...[
                        SectionDivider(string: 'puntual'),
                        ...deserialSchs['null']!.map(
                          (sch) =>
                              ScheduleWidget(schedule: sch, locked: true),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
