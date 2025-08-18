import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/pick_button.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/simple_picker_wrap.dart';

final weekDayChars = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class SimpleWeekdayPicker extends StatelessWidget {
  final Iterable<Schedule>? weeklySchedules;
  const SimpleWeekdayPicker({super.key, required this.weeklySchedules});

  @override
  Widget build(BuildContext context) {
    return SimplePickerWrap(
      period: 'week',
      title: 'weekly',
      isEmpty: weeklySchedules?.isEmpty != false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDayChars.asMap().entries.map<Widget>((e) {
          final sch = Schedule.empty(
            day: (e.key + 1).toString(),
            period: 'week',
          );
          final matches = modelEditPool.getScheduleMatches(sch);
          final selected = matches?.isNotEmpty == true;
          return SizedBox(
            width: 40,
            child: PickButton(
              isToday: DateTime.now().weekday.toString() == sch.day,
              onPressed: () {
                modelEditPool.toggleSimpleSchedule(sch, matches: matches);
              },
              selected: selected,
              str: e.value,
            ),
          );
        }).toList(),
      ),
    );
  }
}
