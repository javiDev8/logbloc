import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/txt.dart';

class ModelSchedulesView extends StatelessWidget {
  const ModelSchedulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
      child: LazySwimmer<Model>(
        pool: modelEditPool,
        listenedEvents: ['schedules'],
        builder: (context, model) => Column(
          children: [
            SectionDivider(lead: AddSchRuleButton()),
            Expanded(
              child: ListView(
                children: [
                  ...(model.schedules ?? []).map(
                    (sch) => ScheduleWidget(schedule: sch, locked: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final color = Theme.of(context).colorScheme.tertiaryContainer;
    late final String day;
    switch (schedule.period) {
      case null:
        day = hdate(DateTime.parse(schedule.day));
        break;
      case 'week':
        day = weekdays[int.parse(schedule.day)];
        break;
    }

    bool expanded = false;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
      ),
      color: themeModePool.data == ThemeMode.dark
          ? endarkColor(color)
          : enbrightColor(color),

      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Row(
                children: [
                  Expanded(child: Txt(day, w: 8)),
                  IconButton(
                    onPressed: () => setState(() => expanded = !expanded),
                    icon: Icon(
                      expanded
                          ? Icons.arrow_drop_up_outlined
                          : Icons.arrow_drop_down_outlined,
                    ),
                  ),
                ],
              ),
              if (expanded)
                Column(
                  children: [
                    Row(
                      children: [
                        Txt('include all features', w: 7),
                        Checkbox(
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
                        //bool expanded = false;
                        return Row(
                          children: [
                            StatefulBuilder(
                              builder: (context, setState) => Checkbox(
                                value:
                                    schedule.includedFts?.contains(
                                      ft.key,
                                    ) ==
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
      ),
    );
  }
}

class AddSchRuleButton extends StatelessWidget {
  const AddSchRuleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        showModalBottomSheet(
          showDragHandle: true,
          isDismissible: false,
          context: context,
          builder: (context) => SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Txt('Pick a schedule period', w: 7, s: 16),
                        Exp(),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('puntual'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(9999),
                      );
                      if (date == null) return;
                      modelEditPool.addSchedule(
                        Schedule.empty(day: strDate(date)),
                      );
                      navPop();
                    },
                  ),
                  ListTile(
                    title: Text('weekly'),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('pick a week day'),
                          content: SizedBox(
                            height: 500,
                            child: Column(
                              children: weekdays
                                  .asMap()
                                  .entries
                                  .map(
                                    (wd) => ListTile(
                                      title: Text(wd.value),
                                      onTap: () {
                                        modelEditPool.addSchedule(
                                          Schedule.empty(
                                            day: wd.key.toString(),
                                            period: 'week',
                                          ),
                                        );
                                        modelEditPool.dirt(true);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      );

                      navPop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
