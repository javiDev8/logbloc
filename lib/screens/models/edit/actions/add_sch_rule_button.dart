import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

class AddSchRuleButton extends StatelessWidget {
  const AddSchRuleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      null,
      variant: 2,
      lead: Icons.add,
      onPressed: () {
        topbarPool.pushTitle(Text('rules'));
        showModalBottomSheet(
          enableDrag: false,
          isDismissible: false,
          context: context,
          builder: (context) => SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Select a scheduling type',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Exp(),
                        IconButton(
                          onPressed: () => navPop(),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('puntual'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(9999),
                      );
                      if (date == null) return;
                      modelEditPool.addSchedule(
                        Schedule.empty(day: strDate(date)),
                      );
                      navPop();
                    },
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
