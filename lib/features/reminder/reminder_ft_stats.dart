import 'package:flutter/material.dart';
import 'package:logize/features/reminder/reminder_ft_class.dart';

class ReminderFtStats extends StatelessWidget {
  final List<Map<String, dynamic>> ftRecs;
  final ReminderFt ft;
  const ReminderFtStats({
    super.key,
    required this.ft,
    required this.ftRecs,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsGeometry.all(50),
        child: Text(
          'This feature currently doesnt have any stats representation available',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
