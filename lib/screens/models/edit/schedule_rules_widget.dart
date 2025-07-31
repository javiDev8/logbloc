import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/daily/daily_screen.dart';
import 'package:logize/screens/models/edit/actions/add_sch_rule_button.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/sch_rule_wrap.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:flutter/material.dart';

class ScheduleRulesWidget extends StatelessWidget {
  const ScheduleRulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LazySwimmer<Model>(
      pool: modelEditPool,
      listenedEvents: ['schedule-rules'],
      builder:
          (context, model) => Column(
            children: [
              SectionDivider(
                string: 'Schedule Rules',
                lead: AddSchRuleButton(),
              ),
              if (model.scheduleRules?.containsKey('week-day') == true)
                SchRuleWrap(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Txt('weeky rules', w: 8),
                              IconButton(
                                onPressed:
                                    () => modelEditPool.removeScheduleKey(
                                      'week-day',
                                    ),
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children:
                              [
                                'm',
                                't',
                                'w',
                                't',
                                'f',
                                's',
                                's',
                              ].asMap().entries.map<Widget>((d) {
                                final selected = model
                                    .scheduleRules!['week-day']!
                                    .containsKey(d.key.toString());
                                return SizedBox(
                                  width: 50,
                                  child: TextButton(
                                    onPressed:
                                        () => modelEditPool.addSchedule({
                                          'week-day': d.key.toString(),
                                        }),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        d.value,
                                        style: TextStyle(
                                          color:
                                              selected
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                  : Colors.white,
                                          fontWeight:
                                              selected
                                                  ? FontWeight.w900
                                                  : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    // style with background color
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              if (model.scheduleRules?.containsKey('day') == true)
                ...model.scheduleRules!['day']!.entries.map<Widget>(
                  (d) => SchRuleWrap(
                    key: Key(d.key),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [
                          Txt(hdate(DateTime.parse(d.key)), w: 8),
                          Button(
                            'pick date',
                            variant: 2,
                            filled: false,
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                currentDate: currentDate,
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(9999),
                              );
                              if (pickedDate == null) return;
                              modelEditPool.data.scheduleRules!['day']!
                                  .remove(d.key);
                              modelEditPool.addSchedule({
                                'day': strDate(pickedDate),
                              });
                            },
                            lead: (Icons.calendar_today),
                          ),
                          IconButton(
                            onPressed:
                                () => modelEditPool.removeSchedule({
                                  'day': d.key,
                                }),
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );
  }
}
