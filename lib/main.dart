import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/notify_service.dart';
import 'core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // 🔥 추가

  // 🔥 알림 초기화
  await NotificationService().initialize();

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
