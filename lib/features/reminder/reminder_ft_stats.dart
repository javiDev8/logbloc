import 'package:flutter/material.dart';
import 'package:logize/features/reminder/reminder_ft_class.dart';
import 'package:logize/widgets/design/txt.dart';

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
    return Txt('unimplemented');
  }
}
