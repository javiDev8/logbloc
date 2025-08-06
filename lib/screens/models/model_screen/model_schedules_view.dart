import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/design/txt.dart';

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

    return StatefulBuilder(
      builder: (context, setState) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
        ),
        color: themeModePool.data == ThemeMode.dark
            ? endarkColor(color)
            : enbrightColor(color),
        child: InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              children: [
                Txt(day, w: 8),

                if (expanded)
                  ...model.features.values.map<Widget>(
                    (ft) => Row(
                      children: [
                        Checkbox(
                          value:
                              schedule.includedFts?.contains(ft.key) ==
                              true,
                          onChanged: (val) {
                            if (val == true &&
                                schedule.includedFts?.contains(ft.key) !=
                                    true) {
                              schedule.includedFts ??= [];
                              schedule.includedFts!.add(ft.key);
                            } else if (val == false &&
                                schedule.includedFts?.contains(ft.key) ==
                                    true) {
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
          ),
        ),
      ),
    );
  }
}

class ModelSchedulesView extends StatelessWidget {
  final Model model;
  const ModelSchedulesView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 20),
      child: ListView(
        children: [
          ...((model.schedules ?? [])).map(
            (sch) =>
                ScheduleWidget(schedule: sch, locked: true, model: model),
          ),
        ],
      ),
    );
  }
}
