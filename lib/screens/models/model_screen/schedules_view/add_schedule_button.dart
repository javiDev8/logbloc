import 'package:flutter/material.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_biweek_picker.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_monthday_picker.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_weekday_picker.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';

class AddScheduleButton extends StatelessWidget {
  final String type;
  final Map<String, List<Schedule>?> deserialSchs;
  const AddScheduleButton({
    super.key,
    required this.type,
    required this.deserialSchs,
  });

  addPuntual(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(9999),
    );
    if (date == null) return;
    modelEditPool.addSchedule(Schedule.empty(day: strDate(date)));
    // ignore: use_build_context_synchronously
    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      null,
      lead: (Icons.add),
      onPressed: () {
        if (type == 'puntual') {
          addPuntual(context);
          return;
        }

        showModalBottomSheet(
          showDragHandle: true,
          isDismissible: false,
          context: context,
          builder: (context) => SizedBox(
            height: 350,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Txt(
                          type == 'all'
                              ? 'Pick a schedule type'
                              : 'Pick a period',
                          w: 7,
                          s: 16,
                        ),
                        Exp(),
                      ],
                    ),
                  ),
                  if (type == 'all')
                    ListTile(
                      title: Text('one time'),
                      onTap: () => addPuntual(context),
                    ),

                  ...periodPickers.entries
                      .where(
                        (ppe) =>
                            // if simple picker already there, skip it
                            modelEditPool.data.simplePeriods?.contains(
                              ppe.key,
                            ) !=
                            true,
                      )
                      .map<Widget>(
                        (ppe) => ListTile(
                          title: Text(ppe.key),
                          onTap: deserialSchs[ppe.key]?.isNotEmpty == true
                              ? () => ppe.value.picker(context)
                              : () {
                                  modelEditPool.setSchedulePeriod(
                                    period: ppe.key,
                                    simple: true,
                                  );
                                  Navigator.of(context).pop();
                                },
                        ),
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

class PeriodPicker {
  Future<void> Function(BuildContext) picker;
  Widget Function(Iterable<Schedule>?) simplePicker;

  PeriodPicker({required this.picker, required this.simplePicker});
}

final periodPickers = {
  'week': PeriodPicker(
    picker: (BuildContext context) async {
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
    simplePicker: (ws) => SimpleWeekdayPicker(weeklySchedules: ws),
  ),

  'bi-week': PeriodPicker(
    picker: (BuildContext context) async {
      final sch = await showDialog(
        context: context,
        builder: (context) => Column(
          children: [Exp(), SimpleBiweekPicker(single: true), Exp()],
        ),
      );
      modelEditPool.addSchedule(sch);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    },
    simplePicker: (bws) => SimpleBiweekPicker(schedules: bws?.toList()),
  ),

  'month': PeriodPicker(
    picker: (BuildContext context) async {
      Schedule schedule = Schedule.empty(period: 'month', day: '1');
      final formKey = GlobalKey<FormState>();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Form(
            key: formKey,
            child: Row(
              children: [
                Expanded(
                  child: TxtField(
                    label: 'month day',
                    round: true,
                    hint: 'mm',
                    onChanged: (str) => schedule.day = str,
                    validator: (str) {
                      if (str == null || str.isEmpty) {
                        return 'is empty';
                      }
                      final number = int.tryParse(str);
                      if (number == null) {
                        return 'invalid number';
                      }
                      if (number < 1 || number > 31) {
                        return 'invalid range';
                      }
                      return null;
                    },
                  ),
                ),
                Button(
                  null,
                  lead: Icons.check_circle_outline,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      modelEditPool.addSchedule(schedule);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    },
    simplePicker: (ms) => SimpleMonthdayPicker(schedules: ms?.toList()),
  ),
};
