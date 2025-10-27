import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
    const channel = AndroidNotificationChannel(
      'timer_channel',
      'Timer',
      description: 'Pomodoro timer notifications',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showSimple(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'timer_channel',
        'Timer',
        priority: Priority.high,
        importance: Importance.high,
      ),
    );
    await _plugin.show(0, title, body, details);
  }
}
