import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logbloc/apis/notifications.dart';
import 'package:logbloc/features/feature_class.dart';
import 'package:logbloc/pools/models/model_edit_pool.dart';

class ReminderFt extends Feature {
  TimeOfDay time;
  int notifId;
  String content;

  ReminderFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    required this.notifId,
    required this.time,
    required this.content,
  });

  factory ReminderFt.fromBareFt(
    Feature ft, {
    required TimeOfDay time,
    required int notifId,
    required String content,
  }) {
    return ReminderFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      content: content,
      notifId: notifId,
      time: time,
    );
  }

  factory ReminderFt.empty() {
    final t = DateTime.now();
    return ReminderFt.fromBareFt(
      Feature.empty('reminder'),
      time: TimeOfDay.now(),
      content: '',
      notifId: int.parse('${t.month}${t.day}${t.hour}${t.minute}${t.second}'),
    );
  }

  factory ReminderFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) {
    final ts = (entry.value['time'] as String).split(':');
    return ReminderFt.fromBareFt(
      Feature.fromEntry(entry),
      time: TimeOfDay(hour: int.parse(ts[0]), minute: int.parse(ts[1])),
      content: entry.value['content'],
      notifId: entry.value['notif-id'],
    );
  }

  @override
  serialize() => {
    ...super.serialize(),
    'time': '${time.hour}:${time.minute}',
    'notif-id': notifId,
    'content': content,
  };

  @override
  FutureOr<bool> onModelSave({String? modelId}) async {
    if (time.compareTo(TimeOfDay.now()) <= 0) {
      // time is on past, nothing to do here
      return true;
    }

    try {
      final schs = modelEditPool.data.getDateSchedules(DateTime.now());
      // schedule only if model schedules match today
      if (schs
              .where((sch) => sch.includedFts?.contains(id) != false)
              .isNotEmpty ==
          true) {
        // schedule only if included, and makes no
        // sense to schedule the same notif on same day
        // so one for all matches is good
        await notif.schedule(
          notifId,
          time: time,
          title: title,
          body: content,
          soundName: 'reminder_notification',
        );
      }
    } catch (e) {
      return false;
    }
    return true;
  }
}
