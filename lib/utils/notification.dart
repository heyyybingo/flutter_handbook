import 'dart:async';
import 'dart:convert';

import 'package:flutter_handbook/utils/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

part 'notification.g.dart';
// class ReceivedNotification {
//   ReceivedNotification({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.payload,
//   });

//   final int id;
//   final String? title;
//   final String? body;
//   final String? payload;
// }

enum NotificationType {
  @JsonValue(1)
  handbook,
}

@JsonSerializable()
class NotificationPayload {
  @JsonKey(name: "type")
  final NotificationType type;
  @JsonKey(name: "value")
  final dynamic value;

  NotificationPayload({required this.type, this.value});

  toJson() => _$NotificationPayloadToJson(this);
  static NotificationPayload fromJson(json) =>
      _$NotificationPayloadFromJson(json);
}

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<NotificationResponse> didReceiveNotificationStream =
    StreamController<NotificationResponse>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

@pragma("vm:entry-point")
void notificationTapBackground(NotificationResponse response) {
  logger.i('onDidReceiveBackgroundNotificationResponse: $response');
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // macos or ios setting
  initDarwinSetting() {
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,

      // notificationCategories: [],
    );

    return initializationSettingsDarwin;
  }

  initTimeZone() async {
    tz.initializeTimeZones();

    final String timeZoneName = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> init() async {
    final initializationSettingsDarwin = initDarwinSetting();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      // android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      // linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        logger.i('onDidReceiveNotificationResponse: $details');
        didReceiveNotificationStream.add(details);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await initTimeZone();
    await requestPermission();
  }

  showNotification(
      {required int id,
      required String title,
      required String body,
      NotificationPayload? payload}) async {
    await flutterLocalNotificationsPlugin.show(id, title, body, null,
        payload: jsonEncode(payload?.toJson()));
  }

  scheduleNotification(
      {required int id,
      required String title,
      required String body,
      required DateTime notifyTime,
      NotificationPayload? payload}) async {
    Duration timeDifference = notifyTime.difference(DateTime.now());
    if (timeDifference.isNegative) {
      await showNotification(
          id: id, title: title, body: body, payload: payload);
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.now(tz.local).add(timeDifference),
          const NotificationDetails(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: jsonEncode(payload?.toJson()));
    }
  }

  cancelNotification({required int id}) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  requestPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}
