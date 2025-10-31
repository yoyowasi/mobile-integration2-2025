import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_integration2_2025/core/router/router.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  // main 함수에서 비동기 작업을 수행하기 위해 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // timezone 라이브러리 초기화
  tz.initializeTimeZones();
  
  // ToStore DB 초기화 (필요시)
  // final db = ToStore();
  // await db.initialize();

  // 앱 실행
  runApp(
    const ProviderScope(
      child: PomodoroApp(),
    ),
  );
}

class PomodoroApp extends ConsumerWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Adaptive Pomodoro',
      routerConfig: appRouter,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}