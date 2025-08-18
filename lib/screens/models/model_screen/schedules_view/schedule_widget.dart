import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/simple_biweek_picker.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/warn_dialogs.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/txt.dart';

class ScheduleWidget extends StatelessWidget {
  final Schedule schedule;
  final bool locked;
  const ScheduleWidget({
    super.key,
    required this.schedule,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    late final String day;
    switch (schedule.period) {
      case null:
        day = hdate(DateTime.parse(schedule.day));
        break;
      case 'week':
        day = weekdays[int.parse(schedule.day)];
        break;
      case 'bi-week':
        final sd = int.parse(schedule.day);
        final nd = int.parse(dateToBiweekDay(DateTime.now()));
        final isThisWeek = sd > 7 && nd > 7 || sd <= 7 && nd <= 7;
        final d = sd > 7 ? sd - 7 : sd;
        day = '${isThisWeek ? 'this' : 'next'} week\'s  ${weekdays[d]}';
        break;
      case 'month':
        day = schedule.day;
        break;
    }

    final editing = modelEditPool.editingSchs.contains(schedule.id);

    remove() {
      warnDelete(
        context,
        preventPop: true,
        delete: () {
          modelEditPool.removeSchedule(schedule.id);
          return true;
        },
        msg: 'Remove schedule?',
      );
    }

    return ScheduleWrap(
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            Row(
              children: [
                Expanded(child: Txt(day, w: 8)),
                if (editing)
                  IconButton(
                    onPressed: remove,
                    icon: Icon(Icons.close),
                    key: UniqueKey(),
                  ),

                IconButton(
                  key: UniqueKey(),
                  onPressed: () {
                    if (editing) {
                      modelEditPool.editingSchs.remove(schedule.id);
                    } else {
                      modelEditPool.editingSchs.add(schedule.id);
                    }
                    modelEditPool.controller.sink.add('schedules');
                  },
                  icon: Icon(
                    editing ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
            if (editing)
              Column(
                children: [
                  if (schedule.period != null) ...[
                    Row(
                      children: [
                        Expanded(child: Txt('start date', w: 7)),
                        Button(
                          hdate(schedule.startDate!),
                          lead: Icons.calendar_month,
                          filled: false,
                          onPressed: () async {
                            final startDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.parse('9999-12-31'),
                            );
                            if (startDate != null) {
                              schedule.startDate = startDate;
                              modelEditPool.dirt(true);
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Txt('skip matches', w: 7),
                        Switch(
                          onChanged: (val) {
                            schedule.skipMatch = val;
                            setState(() => {});
                            modelEditPool.dirt(true);
                          },
                          value: schedule.skipMatch == true,
                        ),
                      ],
                    ),
                  ],

                  if (modelEditPool.data.features.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Txt('include all features', w: 7),
                        Switch(
                          value: schedule.includedFts == null,
                          onChanged: (val) {
                            if (val == true) {
                              schedule.includedFts = null;
                            } else if (val == false) {
                              schedule.includedFts = List<String>.from(
                                modelEditPool.data.features.keys,
                              );
                            }
                            setState(() => {});
                          },
                        ),
                      ],
                    ),
                  if (schedule.includedFts != null)
                    ...modelEditPool.data.features.values.map<Widget>((
                      ft,
                    ) {
                      return Row(
                        children: [
                          StatefulBuilder(
                            builder: (context, setState) => Checkbox(
                              value:
                                  schedule.includedFts?.contains(ft.key) ==
                                  true,
                              onChanged: (val) {
                                modelEditPool.dirt(true);
                                if (val == true &&
                                    schedule.includedFts?.contains(
                                          ft.key,
                                        ) !=
                                        true) {
                                  schedule.includedFts ??= [];
                                  schedule.includedFts!.add(ft.key);
                                } else if (val == false &&
                                    schedule.includedFts?.contains(
                                          ft.key,
                                        ) ==
                                        true) {
                                  schedule.includedFts!.removeWhere(
                                    (ftKey) => ftKey == ft.key,
                                  );
                                }
                                setState(() => {});
                              },
                            ),
                          ),
                          Icon(
                            featureSwitch(
                              parseType: 'icon',
                              ftType: ft.type,
                            ),
                          ),
                          Txt(ft.title, w: 7),
                        ],
                      );
                    }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ScheduleWrap extends StatelessWidget {
  final Widget child;
  const ScheduleWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiaryContainer;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
      ),
      color: themeModePool.data == ThemeMode.dark
          ? endarkColor(color)
          : enbrightColor(color),
      child: Padding(padding: EdgeInsetsGeometry.all(10), child: child),
    );
  }
}
