import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/period_picker_menu_button.dart';
import 'package:logize/widgets/design/sch_rule_wrap.dart';
import 'package:logize/widgets/design/txt.dart';

class SimplePickerWrap extends StatelessWidget {
  final Iterable<Schedule>? schedules;
  final String title;
  final Widget child;
  final String period;
  const SimplePickerWrap({
    super.key,
    required this.schedules,
    required this.title,
    required this.child,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return SchRuleWrap(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Txt(title, w: 8),
                PeriodPickerMenuButton(period: period),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
