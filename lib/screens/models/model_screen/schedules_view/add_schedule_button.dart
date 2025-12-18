import 'package:flutter/material.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_biweek_picker.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_monthday_picker.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_weekday_picker.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/simple_yearday_picker.dart';
import 'package:logbloc/utils/feedback.dart';
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
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(9999),
    );
    if (d == null) return;
    final date = DateTime.parse(strDate(d));
    final nowStr = strDate(DateTime.now());
    if (nowStr != strDate(date) && date.isBefore(DateTime.parse(nowStr))) {
      feedback('choosed date is on past', type: FeedbackType.error);
      return;
    }

    modelEditPool.addSchedule(Schedule.empty(day: strDate(date)));
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
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
            height: double.infinity,
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

                  if (type != 'puntual')
                    ListTile(
                      title: Text('everyday'),
                      onTap: () {
                        modelEditPool.addSchedule(
                          Schedule.empty(
                            day: 'everyday',
                            period: 'everyday',
                          ),
                        );
                        Navigator.of(context).pop();
                      },
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

                          onTap:
                              ppe.key == 'year' ||
                                  deserialSchs[ppe.key]?.isNotEmpty == true
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

bool isValidDay(int month, int day) {
  if (month == 2) return day <= 29;
  if ([4, 6, 9, 11].contains(month)) return day <= 30;
  return true;
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

  'year': PeriodPicker(
    picker: (BuildContext context) async {
      int? selectedMonth;
      int? selectedDay;
      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Pick yearly date'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Month'),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(12, (i) => i + 1)
                      .map(
                        (m) => SizedBox(
                          width: 70,
                          height: 36,
                          child: TextButton(
                            onPressed: () =>
                                setState(() => selectedMonth = m),
                            style: TextButton.styleFrom(
                              backgroundColor: selectedMonth == m
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              foregroundColor: selectedMonth == m
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                            child: Text(
                              months[m],
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 20),
                Text('Day'),
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: List.generate(31, (i) => i + 1)
                      .map(
                        (d) => SizedBox(
                          width: 32,
                          height: 32,
                          child: TextButton(
                            onPressed:
                                selectedMonth == null ||
                                    !isValidDay(selectedMonth!, d)
                                ? null
                                : () => setState(() => selectedDay = d),
                            style: TextButton.styleFrom(
                              backgroundColor: selectedDay == d
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              foregroundColor: selectedDay == d
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(32, 32),
                            ),
                            child: Text(
                              d.toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: selectedMonth != null && selectedDay != null
                    ? () {
                        final dayStr =
                            '${selectedMonth!.toString().padLeft(2, '0')}-${selectedDay!.toString().padLeft(2, '0')}';
                        final schedule = Schedule.empty(
                          period: 'year',
                          day: dayStr,
                        );
                        modelEditPool.addSchedule(schedule);
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Text('OK'),
              ),
            ],
          ),
        ),
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    },
    simplePicker: (ys) => SimpleYeardayPicker(schedules: ys?.toList()),
  ),
};
