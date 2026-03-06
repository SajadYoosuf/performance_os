import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Cross-platform notification service.
///
/// Uses flutter_local_notifications for Android/iOS.
/// Falls back to a no-op on web (web notifications not supported by the plugin).
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialise the notification plugin. Call once in `main()`.
  Future<void> init() async {
    if (kIsWeb || _initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Show a simple notification.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || !_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'performance_os_tasks',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification at a specific time.
  Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime scheduledAt,
  }) async {
    if (kIsWeb || !_initialized) return;

    // Use show() for now; scheduling requires timezone setup.
    // For immediate reminders, fall through to show().
    await show(
      id: id,
      title: '⏰ Task Reminder',
      body: taskTitle,
      payload: 'task_$id',
    );
  }

  /// Notify user of task completion.
  Future<void> notifyTaskCompleted(String taskTitle) async {
    await show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '✅ Task Completed!',
      body: '"$taskTitle" has been marked as done.',
    );
  }

  /// Notify user of overdue tasks.
  Future<void> notifyOverdueTasks(int count) async {
    if (count <= 0) return;
    await show(
      id: 99999,
      title: '⚠️ Overdue Tasks',
      body:
          'You have $count overdue task${count > 1 ? 's' : ''}. Time to catch up!',
    );
  }

  /// Daily motivation notification.
  Future<void> notifyDailyMotivation(int pendingCount) async {
    await show(
      id: 88888,
      title: '🚀 Good morning!',
      body: 'You have $pendingCount tasks today. Let\'s make it productive!',
    );
  }
}
