import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

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

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 클릭 시 동작 (필요하면 추가)
      },
    );

    // 🔥 Android 13+ 권한 요청
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  /// 타이머 완료 알림
  Future<void> showCompletionNotification({
    required int minutes,
    required String mode,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: '뽀모도로 타이머 완료 알림',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
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
      '🎉 집중 완료!',
      '$minutes분 집중을 완료했습니다. 잠시 휴식을 취하세요.',
      details,
    );
  }

  /// 휴식 시작 알림 (선택)
  // Future<void> showBreakNotification() async {
  //   const AndroidNotificationDetails androidDetails =
  //   AndroidNotificationDetails(
  //     'pomodoro_channel',
  //     'Pomodoro Timer',
  //     channelDescription: '뽀모도로 타이머 알림',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //   );
  //
  //   const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //
  //   const NotificationDetails details = NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );
  //
  //   await _notifications.show(
  //     1,
  //     '☕ 휴식 시간',
  //     '5분간 휴식하세요!',
  //     details,
  //   );
  // }
}
