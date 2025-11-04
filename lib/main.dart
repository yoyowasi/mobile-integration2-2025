// main.dart (간단 예시)
import 'package:flutter/material.dart';
import 'screens/timer_screen.dart';

void main() {
  // 플러터 위젯 바인딩 (필요 시 초기화 작업 전에 호출)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 기본 머티리얼 앱 설정
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      title: 'Adaptive Pomodoro',
      // 머티리얼3 사용(선택)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE74D50), // 포인트 컬러(빨강톤)
        fontFamily: 'Pretendard', // 폰트 사용 시 pubspec에 등록 필요
      ),
      // 앱 시작 시 바로 타이머 화면 보여주기
      home: const TimerScreen(),
    );
  }
}