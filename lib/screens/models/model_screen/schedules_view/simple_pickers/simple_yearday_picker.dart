import 'package:flutter/material.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_picker_wrap.dart';

class SimpleYeardayPicker extends StatelessWidget {
  final List<Schedule>? schedules;
  const SimpleYeardayPicker({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    return SimplePickerWrap(
      isEmpty: schedules?.isEmpty != false,
      period: 'year',
      title: 'yearly',
      child: SizedBox(
        width: 350,
        child: ElevatedButton(
          onPressed: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(9999),
            );
            if (d == null) return;
            final day =
                '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
            final sch = Schedule.empty(period: 'year', day: day);
            modelEditPool.toggleSimpleSchedule(sch, matches: null);
          },
          child: Text('Pick a date'),
        ),
      ),
    );
  }
}
