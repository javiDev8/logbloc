import 'package:logize/config/locales.dart';
import 'package:logize/features/feature_class.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/features/number/number_ft_class.dart';
import 'package:logize/features/number/number_ft_stats_widget.dart';
import 'package:logize/features/number/number_ft_widget.dart';
import 'package:logize/features/task_list/task_list_ft_class.dart';
import 'package:logize/features/task_list/task_list_ft_stats.dart';
import 'package:logize/features/task_list/task_list_ft_widget.dart';
import 'package:logize/features/text/text_ft_class.dart';
import 'package:logize/features/text/text_ft_stats.dart';
import 'package:logize/features/text/text_ft_widget.dart';
import 'package:flutter/material.dart';

final List<String> availableFtTypes = [
  'number',
  'text',
  'task_list',
];

dynamic featureSwitch({
  required String parseType,

  bool? detailed,
  String? ftType,
  FeatureLock? lock,
  Feature? ft,
  MapEntry<String, dynamic>? entry,
  Map<String, dynamic>? recordFt,
  List<Map<String, dynamic>>? ftRecs,
}) {
  final type =
      ftType ?? (entry == null ? ft!.type : entry.key.split('-')[0]);
  switch (type) {
    case 'number':
      switch (parseType) {
        case 'class':
          return entry == null
              ? NumberFt.empty()
              : NumberFt.fromEntry(entry, recordFt);
        case 'widget':
          return NumberFtWidget(
            lock: lock!,
            ft: ft as NumberFt,
            detailed: detailed!,
          );
        case 'stats':
          return NumberFtStatsWidget(ftRecs: ftRecs!, ft: ft as NumberFt);
        case 'label':
          return TrText(Tr.ftNumberLabel);
        case 'icon':
          return Icons.square_foot;
      }

    case 'text':
      switch (parseType) {
        case 'class':
          return entry == null
              ? TextFt.empty()
              : TextFt.fromEntry(entry, recordFt);
        case 'widget':
          return TextFtWidget(
            lock: lock!,
            ft: ft as TextFt,
            detailed: detailed!,
          );
        case 'stats':
          return TextFtStatsWidget(ftRecs: ftRecs!, ft: ft as TextFt);
        case 'label':
          return Text('text');
        case 'icon':
          return Icons.text_format;
      }

    case 'task_list':
      switch (parseType) {
        case 'class':
          return entry == null
              ? TaskListFt.empty()
              : TaskListFt.fromEntry(entry, recordFt);
        case 'widget':
          return TaskListFtWidget(
            lock: lock!,
            ft: ft as TaskListFt,
            detailed: detailed!,
          );
        case 'stats':
          return TaskListFtStatsWidget(
            ftRecs: ftRecs!,
            ft: ft as TaskListFt,
          );
        case 'label':
          return Text('task list');
        case 'icon':
          return Icons.list;
      }

    default:
      throw Exception('uknown feature type');
  }
}
