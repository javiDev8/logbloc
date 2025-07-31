import 'package:flutter/material.dart';

const List<String> weekdays = [
  '', // Weekday is 1-indexed, so index 0 is empty
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> months = [
  '', // Month is 1-indexed
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String strDate(DateTime d) => d.toString().split(' ')[0];
String slashDate(DateTime d) {
  final parts = d.toString().split(' ')[0].split('-').reversed.toList();
  parts[2] = '${parts[2].split('')[2]}${parts[2].split('')[3]}';
  return parts.join('/');
}

// humanize date
String hdate(DateTime date) {
  //final String dayOfWeek = weekdays[date.weekday];
  final String dayOfMonth = date.day.toString().padLeft(2, '0');
  final String month = months[date.month];
  final String year = date.year.toString();

  return '$dayOfMonth $month $year';
}

TimeOfDay timeFromString(String timeOfDayString) {
  final int startIndex = timeOfDayString.indexOf('(');
  final int endIndex = timeOfDayString.lastIndexOf(')');
  if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
    throw FormatException(
      'Invalid TimeOfDay string format: "$timeOfDayString". Expected "TimeOfDay(HH:MM)".',
    );
  }
  String timePart = timeOfDayString.substring(
    startIndex + 1,
    endIndex,
  ); // Extracts "HH:MM"
  List<String> parts = timePart.split(':');
  if (parts.length != 2) {
    throw FormatException(
      'Invalid time format in string: "$timePart". Expected "HH:MM".',
    );
  }
  try {
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException(
        'Hour or minute out of valid range: $hour:$minute',
      );
    }
    return TimeOfDay(hour: hour, minute: minute);
  } on FormatException catch (e) {
    throw FormatException(
      'Failed to parse time components from "$timePart": ${e.message}',
    );
  }
}
