import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleMonthlyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfMonth,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDay(dayOfMonth),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bill_reminders',
          'Bill Reminders',
          channelDescription: 'Reminders for fixed expenses',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> showBudgetAlert(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications for budget thresholds',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      999, // Fixed ID for budget alerts
      title,
      body,
      platformChannelSpecifics,
    );
  }

  tz.TZDateTime _nextInstanceOfDay(int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Helper to get valid day for a month
    int getValidDay(int year, int month, int requestedDay) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      return requestedDay > daysInMonth ? daysInMonth : requestedDay;
    }

    // Try to schedule for this month
    int validDay = getValidDay(now.year, now.month, day);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, validDay, 10, 0);

    // If this month's date is in the past, schedule for next month
    if (scheduledDate.isBefore(now)) {
      int nextMonth = now.month + 1;
      int nextYear = now.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear = now.year + 1;
      }
      
      validDay = getValidDay(nextYear, nextMonth, day);
      scheduledDate = tz.TZDateTime(tz.local, nextYear, nextMonth, validDay, 10, 0);
    }
    
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
