import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/pick_button.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/simple_picker_wrap.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/simple_weekday_picker.dart';

String dateToBiweekDay(DateTime date) {
  final refDate = DateTime.parse('2025-08-11');
  final weekDiff = ((date.difference(refDate).inDays) / 7).round();
  final isFirst = weekDiff % 2 == 0;
  final dateWeekDay = date.weekday;
  return (isFirst ? dateWeekDay : dateWeekDay + 7).toString();
}

class SimpleBiweekPicker extends StatelessWidget {
  final List<Schedule> schedules;
  const SimpleBiweekPicker({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    return SimplePickerWrap(
      title: 'bi week',
      period: 'bi-week',
      child: Column(
        children: [
          ...['A', 'B'].map(
            (w) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDayChars.asMap().entries.map((wdce) {
                final sch = Schedule.empty(
                  period: 'bi-week',
                  day: (wdce.key + (w == 'A' ? 1 : 8)).toString(),
                );
                final matches = modelEditPool.getScheduleMatches(sch);
                final nowBiweekDay = dateToBiweekDay(DateTime.now());
                return SizedBox(
                  width: 40,
                  child: PickButton(
                    isToday: nowBiweekDay == sch.day,
                    onPressed: () {
                      modelEditPool.toggleSimpleSchedule(
                        sch,
                        matches: matches,
                      );
                    },
                    selected: matches?.isNotEmpty == true,
                    str: wdce.value,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
