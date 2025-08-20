import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logize/pools/items/items_by_day_pool.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/screens/daily/daily_screen.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

class PrettyDate extends StatelessWidget {
  final DateTime date;

  const PrettyDate({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final String dayOfWeek = weekdays[date.weekday];
    final String dayOfMonth = date.day.toString().padLeft(2, '0');
    final String month = months[date.month];
    final y = date.year.toString().split('');
    final year = '${y[2]}${y[3]}';

    final color =
        DateTime.now().toString().split(' ')[0] ==
            date.toString().split(' ')[0]
        ? seedColor
        : themeModePool.data == ThemeMode.light
        ? Colors.black
        : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        spacing: 4.0,
        children: <Widget>[
          Text(
            dayOfWeek,
            style: TextStyle(fontWeight: FontWeight.normal, color: color),
          ),
          Exp(),
          Text(
            dayOfMonth,
            style: TextStyle(fontWeight: FontWeight.w900, color: color),
          ),
          Text(
            month,
            style: TextStyle(fontWeight: FontWeight.normal, color: color),
          ),
          Text(
            year,
            style: TextStyle(fontWeight: FontWeight.w200, color: color),
          ),
          IconButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                //currentDate: currentDatePool.data,
                currentDate: DateTime.now(),
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(9999),
              );
              if (pickedDate == null) return;
              initDate = pickedDate;
              currentDatePool.set((_) => pickedDate);
              itemsByDayPool.clean();
            },
            icon: Icon(MdiIcons.calendarSearch),
          ),
        ],
      ),
    );
  }
}
