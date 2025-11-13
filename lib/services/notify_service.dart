import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // timezone 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 설정
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Android 권한 요청
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> showTimerCompleteNotification({
    required String mode,
    required int minutes,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'pomodoro_timer',
      '포모도로 타이머',
      channelDescription: '타이머 완료 알림',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,

    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '🎉 타이머 완료!',
      '$minutes분 ${mode == 'auto' ? '오토' : '커스텀'} 세션이 끝났습니다.',
      details,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

}
