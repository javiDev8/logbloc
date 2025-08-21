import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logize/utils/noticable_print.dart';

final FlutterLocalNotificationsPlugin notifs =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher_foreground');
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();

final InitializationSettings notifsSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsDarwin,
);

void notifResponseCallback(
  NotificationResponse notificationResponse,
) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    nPrint('notification payload: $payload');
  }
}

requestNotifPermission() {
  if (Platform.isAndroid) {
    notifs
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()!
        .requestNotificationsPermission();
  } else if (Platform.isIOS) {
    notifs
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()!
        .requestPermissions();
  }
}
