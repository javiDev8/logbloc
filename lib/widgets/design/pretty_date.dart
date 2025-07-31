import 'package:logize/pools/items/items_by_day_pool.dart';
import 'package:logize/pools/topbar_pool.dart';
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
    final String year = date.year.toString();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        spacing: 4.0,
        children: <Widget>[
          Text(
            dayOfWeek,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Exp(),
          Text(
            dayOfMonth,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
          Text(
            month,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
          Text(year, style: const TextStyle(fontWeight: FontWeight.w200)),
          IconButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                currentDate: currentDate,
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(9999),
              );
              if (pickedDate == null) return;
              topbarPool.setCurrentTitle(PrettyDate(date: pickedDate));
              initDate = pickedDate;
              currentDate = pickedDate;
              itemsByDayPool.clean();
            },
            icon: Icon(Icons.calendar_month),
          ),
        ],
      ),
    );
  }
}
