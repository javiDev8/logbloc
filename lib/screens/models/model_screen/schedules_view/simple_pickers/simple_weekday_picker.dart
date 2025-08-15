import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/pick_button.dart';

class SimpleWeekdayPicker extends StatelessWidget {
  final Iterable<Schedule>? weeklySchedules;
  const SimpleWeekdayPicker({super.key, required this.weeklySchedules});

  @override
  Widget build(BuildContext context) {
    return ScheduleWrap(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['m', 't', 'w', 't', 'f', 's', 's']
            .asMap()
            .entries
            .map<Widget>((e) {
              final sch = Schedule.empty(
                day: (e.key + 1).toString(),
                period: 'week',
              );
              final matches = modelEditPool.getScheduleMatches(sch);
              final selected = matches?.isNotEmpty == true;
              return SizedBox(
                width: 40,
                child: PickButton(
                  onPressed: () {
                    modelEditPool.toggleSimpleSchedule(
                      sch,
                      matches: matches,
                    );
                  },
                  selected: selected,
                  str: e.value,
                ),
              );
            })
            .toList(),
      ),
    );
  }
}
