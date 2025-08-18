import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/pick_button.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/simple_picker_wrap.dart';

class SimpleMonthdayPicker extends StatelessWidget {
  final List<Schedule>? schedules;
  const SimpleMonthdayPicker({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    return SimplePickerWrap(
      isEmpty: schedules?.isEmpty != false,
      period: 'month',
      title: 'monthly',
      child: SizedBox(
        width: 350,
        child: Wrap(
          children: List.generate(31, (i) => (i + 1).toString())
              .map<Widget>((day) {
                final sch = Schedule.empty(period: 'month', day: day);
                final matches = modelEditPool.getScheduleMatches(
                  sch,
                  schList: schedules,
                );
                final selected = matches?.isNotEmpty == true;
                return SizedBox(
                  width: 44,
                  child: PickButton(
                    isToday: DateTime.now().day.toString() == day,
                    onPressed: () {
                      modelEditPool.toggleSimpleSchedule(
                        sch,
                        matches: matches,
                      );
                    },
                    selected: selected,
                    str: day,
                  ),
                );
              })
              .toList(),
        ),
      ),
    );
  }
}
