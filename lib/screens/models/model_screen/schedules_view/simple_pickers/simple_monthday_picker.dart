import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/pick_button.dart';

class SimpleMonthdayPicker extends StatelessWidget {
  const SimpleMonthdayPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ScheduleWrap(
      child: SizedBox(
        width: 350,
        child: Wrap(
          children: List.generate(31, (i) => (i + 1).toString())
              .map<Widget>((day) {
                final sch = Schedule.empty(period: 'month', day: day);
                final matches = modelEditPool.getScheduleMatches(sch);
                final selected = matches?.isNotEmpty == true;
                return SizedBox(
                  width: 43,
                  child: PickButton(
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
