import 'package:flutter/material.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/simple_pickers/period_picker_menu_button.dart';
import 'package:logbloc/widgets/design/txt.dart';

class SimplePickerWrap extends StatelessWidget {
  final String title;
  final Widget child;
  final String period;
  final bool? single;
  final bool isEmpty;
  const SimplePickerWrap({
    super.key,
    required this.title,
    required this.child,
    required this.period,
    required this.isEmpty,
    this.single,
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
                if (single != true && isEmpty != true)
                  PeriodPickerMenuButton(period: period),
                if (isEmpty != false)
                  IconButton(
                    onPressed: () =>
                        modelEditPool.removeSimplePeriod(period: period),
                    icon: Icon(Icons.close),
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
