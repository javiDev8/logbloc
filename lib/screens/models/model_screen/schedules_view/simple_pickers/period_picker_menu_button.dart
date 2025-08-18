import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/widgets/design/menu_button.dart';

class PeriodPickerMenuButton extends StatelessWidget {
  final String period;
  const PeriodPickerMenuButton({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return MenuButton(
      onSelected: (val) {
        switch (val) {
          case 'delete':
            modelEditPool.removeSimplePeriod(period: period);
            break;
        }
      },
      options: [
        MenuOption(
          value: 'delete',
          widget: ListTile(
            title: Text('delete'),
            leading: Icon(Icons.delete),
          ),
        ),
        MenuOption(
          value: 'turn advanced',
          widget: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('advanced'),
              StatefulBuilder(
                builder: (context, setState) => Switch(
                  value:
                      modelEditPool.data.simplePeriods?.contains(period) !=
                      true,
                  onChanged: (val) {
                    modelEditPool.setSchedulePeriod(
                      period: period,
                      simple: !val,
                    );
                    setState(() => {});
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
