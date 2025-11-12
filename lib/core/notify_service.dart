// lib/core/notify_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifyService {
  NotifyService._();
  static final NotifyService instance = NotifyService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: androidInit, iOS: null, macOS: null);
    await _plugin.initialize(init);
    _inited = true;
  }

  Future<void> showDone(String title, String body) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_done',
      'Pomodoro Done',
      channelDescription: 'Timer finished notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(1001, title, body, details);
  }
}
