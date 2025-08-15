import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/screens/models/model_screen/schedules_view/add_schedule_button.dart';
import 'package:logize/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/simple_monthday_picker.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/simple_weekday_picker.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/txt.dart';

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
          final weeklySchedules = model.schedules?.values.where(
            (sch) => sch.period == 'week',
          );
          final monthlySchedules = model.schedules?.values.where(
            (sch) => sch.period == 'month',
          );

          return StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: ['periodic', 'puntual', 'all']
                        .map(
                          (t) => Button(
                            t,
                            variant: 2,
                            onPressed: () => setState(() => showing = t),
                            filled: showing == t,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if (showing == 'all' || showing == 'periodic')
                        Card(
                          color: themeModePool.data == ThemeMode.dark
                              ? endarkColor(Colors.grey)
                              : enbrightColor(Colors.grey),
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionDivider(
                                  string: 'Periodic shedules',
                                  lead: model.simpleScheduling == true
                                      ? null
                                      : AddScheduleButton(),
                                ),

                                Row(
                                  children: [
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Txt('advanced'),
                                        Switch(
                                          value:
                                              model.simpleScheduling !=
                                              true,
                                          onChanged: (val) => modelEditPool
                                              .setAdvanced(val),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                if (model.simpleScheduling == true ||
                                    weeklySchedules?.isNotEmpty == true)
                                  Txt('weekly', w: 7),

                                if (model.simpleScheduling == true)
                                  SimpleWeekdayPicker(
                                    weeklySchedules: weeklySchedules,
                                  ),

                                if (model.simpleScheduling != true &&
                                    weeklySchedules?.isNotEmpty == true)
                                  ...weeklySchedules!.map(
                                    (sch) => ScheduleWidget(
                                      schedule: sch,
                                      locked: true,
                                    ),
                                  ),

                                if (model.simpleScheduling == true ||
                                    monthlySchedules?.isNotEmpty == true)
                                  Txt('Monthly', w: 7),

                                if (model.simpleScheduling == true)
                                  SimpleMonthdayPicker(),

                                if (model.simpleScheduling != true &&
                                    monthlySchedules?.isNotEmpty == true)
                                  ...monthlySchedules!.map(
                                    (sch) => ScheduleWidget(
                                      schedule: sch,
                                      locked: true,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      if (showing == 'all' || showing == 'puntual') ...[
                        SectionDivider(
                          string: 'Puntual',
                          lead: IconButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(9999),
                              );
                              if (date == null) return;
                              modelEditPool.addSchedule(
                                Schedule.empty(day: strDate(date)),
                              );
                            },
                            icon: Icon(Icons.add),
                          ),
                        ),

                        if (model.schedules?.isNotEmpty == true)
                          ...(model.schedules!.values)
                              .where((sch) => sch.period == null)
                              .map(
                                (sch) => ScheduleWidget(
                                  schedule: sch,
                                  locked: true,
                                ),
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
