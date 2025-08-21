import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logize/utils/noticable_print.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notif {
  static const AndroidInitializationSettings
  initializationSettingsAndroid = AndroidInitializationSettings(
    'ic_launcher_foreground',
  );
  static const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  final plugin = FlutterLocalNotificationsPlugin();

  init() async {
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
}

final notif = Notif();
