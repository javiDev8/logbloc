import 'package:flutter/material.dart';
import 'package:logize/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logize/screens/models/model_screen/schedules_view/simple_pickers/period_picker_menu_button.dart';
import 'package:logize/widgets/design/txt.dart';

class SimplePickerWrap extends StatelessWidget {
  final String title;
  final Widget child;
  final String period;
  const SimplePickerWrap({
    super.key,
    required this.title,
    required this.child,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return ScheduleWrap(
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
