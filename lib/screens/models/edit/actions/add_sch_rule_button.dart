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
          builder:
              (context) => SizedBox(
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
                        title: Text('day'),
                        onTap: () {
                          modelEditPool.addScheduleRuleKey('day');
                          modelEditPool.addSchedule({
                            'day': strDate(DateTime.now()),
                          });
                          navPop();
                        },
                      ),
                      ListTile(
                        title: Text('weekly'),
                        onTap: () {
                          modelEditPool.addScheduleRuleKey('week-day');
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
