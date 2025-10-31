import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  runApp(
    const ProviderScope(
      child: PomodoroApp(),
    ),
  );
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Adaptive Pomodoro',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Adaptive Pomodoro'),
        ),
        body: const Center(
          child: Text('앱 초기 상태입니다.'),
        ),
      ),
    );
  }
}