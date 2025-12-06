import 'package:flutter/material.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/add_schedule_button.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/period_picker_menu_button.dart';
import 'package:logbloc/utils/noticable_print.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/section_divider.dart';

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

          nPrint('deserial schs: $deserialSchs');

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

		      ...Schedule.periods.expand<Widget>((period) {
                          if (model.simplePeriods?.contains(period) ==
                              true) {
                            return [
                              periodPickers[period]!.simplePicker(
                                deserialSchs[period],
                              ),
                            ];
                          } else if (deserialSchs[period]?.isNotEmpty ==
                              true) {
                            return [
                              SectionDivider(
                                string: period,
                                lead: PeriodPickerMenuButton(
                                  period: period!,
                                ),
                              ),
                              ...deserialSchs[period]!.map(
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
