import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/txt_field.dart';

class AddScheduleButton extends StatelessWidget {
  const AddScheduleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        if (modelEditPool.data.simpleScheduling == true) {
          return;
        }
        showModalBottomSheet(
          showDragHandle: true,
          isDismissible: false,
          context: context,
          builder: (context) => SizedBox(
            height: 250,
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
                  ListTile(
                    title: Text('monthly'),
                    onTap: () async {
                      Schedule schedule = Schedule.empty(
                        period: 'month',
                        day: '1',
                      );
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
