import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logize/apis/db.dart';
import 'package:logize/features/reminder/reminder_ft_class.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/noticable_print.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

class Notif {
  static const AndroidInitializationSettings
  initializationSettingsAndroid = AndroidInitializationSettings(
    'ic_launcher_foreground',
  );
  static const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  final plugin = FlutterLocalNotificationsPlugin();

  init() async {
    try {
      final InitializationSettings notifsSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      tz.initializeTimeZones();
      tz.setLocalLocation(
        tz.getLocation(await FlutterTimezone.getLocalTimezone()),
      );

      await plugin.initialize(
        notifsSettings,
        onDidReceiveNotificationResponse: notifResponseCallback,
      );

      await Workmanager().initialize(workmanagerCallback);

      final now = DateTime.now();
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      final initialDelay = nextMidnight.difference(now);
      await Workmanager().registerPeriodicTask(
        "schedule-notifications",
        "notifs",
        frequency: Duration(hours: 24),
        initialDelay: initialDelay,
      );
    } catch (e) {
      nPrint('notifs init failed: $e');
    }
  }

  void notifResponseCallback(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      nPrint('notification payload: $payload');
    }
  }

  Future requestNotifPermission() async {
    if (Platform.isAndroid) {
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!
          .requestPermissions();
    }
  }

  schedule(
    int id, {
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      await plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        ),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'logize-notifs',
            'logize notification channel',
            channelDescription:
                'The android notifications channel for the logize application',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      nPrint('after schedule await');
    } catch (e) {
      nPrint('scheduling error! $e');
    }
  }

  test() async {
    try {
      await plugin.show(
        0,
        'test',
        'body test',
        NotificationDetails(
          android: AndroidNotificationDetails('logize', 'sa'),
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'payload',
      );
      nPrint('after await');
    } catch (e) {
      nPrint('EXCEPTIONP: $e');
    }
  }

  @pragma('vm:entry-point')
  void workmanagerCallback() {
    Workmanager().executeTask((task, inputData) async {
      await db.init();
      await modelsPool.retrieve();

      final todayItems = modelsPool.getDayItems(strDate(DateTime.now()));

      if (todayItems == null) {
        return true;
      }

      await notif.init();

      for (final item in todayItems) {
        final reminders = item.model!.features.values.where(
          (ft) => ft.type == 'reminder',
        );

        for (final reminder in reminders) {
          final r = reminder as ReminderFt;
          await notif.schedule(
            r.notifId,
            time: r.time,
            title: r.title,
            body: r.content,
          );
        }
      }

      return true;
    });
  }
}

final notif = Notif();
