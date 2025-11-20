import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 👇 [1] 이 import 문을 꼭 추가해야 합니다!
import 'package:intl/date_symbol_data_local.dart';
import 'core/notify_service.dart';
import 'core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 초기화
  await NotificationService().initialize();

  await initializeDateFormatting();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Adaptive Pomodoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE74D50)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}