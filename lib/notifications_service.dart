import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones(); // Initialize time zone database
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    if (timeZoneName != null) {
      tz.setLocalLocation(tz.getLocation(timeZoneName)); // Set local time zone
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll(); // Cancel all notifications
  }

  Future<void> zonedSchedule(
      int id, final String title, String body, int hour, int minute) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'Heallthyme 101',
          'Healthyme',
          channelDescription: 'Heallthyme notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    required DateTimeComponents matchDateTimeComponents,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: androidScheduleMode,
      uiLocalNotificationDateInterpretation:
          uiLocalNotificationDateInterpretation,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  Future<void> scheduleDailyReminders() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Reminders for meditation and mindful walks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    // Schedule meditation reminders from 8 AM to 6 PM every hour
    for (int hour = 8; hour <= 18; hour++) {
      await zonedSchedule(
        hour, // Unique ID for each notification
        'Meditation Reminder',
        'Take 5 minutes to meditate so rest of your hour goes mindfully',
        hour, 0, // 8:00, 9:00, ..., 18:00
      );
    }

    // Schedule mindful walk reminder at 6:30 PM
    await zonedSchedule(
      19, // Unique ID for the notification
      'Mindful Walk Reminder',
      'Time for a mindful walk!',
      18, 30, // 6:30 PM
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now =
        tz.TZDateTime.now(tz.local); // Use local time zone
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, // Use local time zone
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
