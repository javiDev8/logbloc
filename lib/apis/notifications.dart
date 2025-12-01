import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logbloc/apis/db.dart';
import 'package:logbloc/features/reminder/reminder_ft_class.dart';
import 'package:logbloc/pools/models/model_class.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/parse_map.dart';
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

  static Duration timeUntilMidnight() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  static const details = NotificationDetails(
    iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
    android: AndroidNotificationDetails(
      'logbloc-notifs',
      'logbloc notification channel',
      channelDescription:
          'The android notifications channel for the logbloc application',
    ),
  );

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
      await Workmanager().registerOneOffTask(
        'notifications-schedulation',
        'notifications',
        initialDelay: timeUntilMidnight(),
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  void notifResponseCallback(
    NotificationResponse notificationResponse,
  ) async {}

  Future<bool?> requestNotifPermission() async {
    if (Platform.isAndroid) {
      return await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iosPlugin = plugin.resolvePlatformSpecificImplementation<
	IOSFlutterLocalNotificationsPlugin>();

      await iosPlugin?.requestPermissions(
	alert: true,
	badge: true,
	sound: true,
      );
      final permissions = await iosPlugin?.checkPermissions();

      return 
	permissions?.isAlertEnabled == true ||
	permissions?.isBadgeEnabled == true ||
        permissions?.isSoundEnabled == true;
    } else {
      // no supported platform
      return null;
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
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  trigger({
    required String title,
    required String body,
    required int id,
  }) async =>
      await plugin.show(id, title, body, details, payload: 'payload');
}

@pragma('vm:entry-point')
void workmanagerCallback() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // doesnt need init because will only use schedule method
      final db = HiveDB();
      final modelsPool = ModelsPool(null);

      await db.init();

      final serialModels = await db.models!.getAllValues();
      modelsPool.data = serialModels.map<String, Model>((key, value) {
        final model = Model.fromMap(map: parseMap(value));
        return MapEntry(key.toString(), model);
      });

      final todayItems = modelsPool.getDayItems(strDate(DateTime.now()));

      if (todayItems == null) {
        return true;
      }

      final plugin = FlutterLocalNotificationsPlugin();

      for (final item in todayItems) {
        final reminders = modelsPool.data![item.modelId]!.features.values
            .where((ft) => ft.type == 'reminder');

        for (final reminder in reminders) {
          final r = reminder as ReminderFt;

          // trigger now if time is on past
          // (maybe device was off at 00:00)
          if (r.time.compareTo(TimeOfDay.now()) <= 0) {
            await plugin.show(
              r.notifId,
              r.title,
              r.content,
              Notif.details,
              payload: 'payload',
            );
            return true;
          }

          tz.initializeTimeZones();
          tz.setLocalLocation(
            tz.getLocation(await FlutterTimezone.getLocalTimezone()),
          );
          final now = tz.TZDateTime.now(tz.local);
          await plugin.zonedSchedule(
            r.notifId,
            r.title,
            r.content,
            tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day,
              r.time.hour,
              r.time.minute,
            ),
            Notif.details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }

      await Workmanager().registerOneOffTask(
        'logbloc-${DateTime.now().millisecondsSinceEpoch}',
        'test',
        initialDelay: Notif.timeUntilMidnight(),
      );

      return true;
    } catch (e) {
      return true;
    }
  });
}

final notif = Notif();
