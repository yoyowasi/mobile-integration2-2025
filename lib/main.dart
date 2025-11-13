// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_integration2_2025/services/notify_service.dart';
import 'screens/timer_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 알림 초기화
  await NotificationService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Pomodoro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE74D50),
        fontFamily: 'Pretendard',
      ),
      home: const TimerScreen(),
    );
  }
}
