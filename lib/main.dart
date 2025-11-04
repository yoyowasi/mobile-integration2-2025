// main.dart (간단 예시)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_integration2_2025/providers/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pomodoro Timer')),
        body: settings.when(
          data: (s) => Center(
            child: Text('현재 모드: ${s.mode} / 집중 ${s.focus}분'),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('설정 불러오기 실패'),
        ),
      ),
    );
  }
}
