import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/dial/dial_canvas.dart';
import '../widgets/controls/control_bar.dart';

/// 단순 동작 확인용 데모 스크린
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final int totalMinutes = 25; // 기본 25분
  Timer? _ticker;
  int elapsed = 0;             // 경과 초
  bool running = false;

  void _start() {
    if (running) return;
    setState(() => running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        elapsed++;
        if (elapsed >= totalMinutes * 60) {
          running = false;
          _ticker?.cancel();
        }
      });
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => running = false);
  }

  void _toggle() => running ? _pause() : _start();

  void _reset() {
    _ticker?.cancel();
    setState(() {
      elapsed = 0;
      running = false;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: PomodoroDial(totalMinutes: totalMinutes, elapsedSeconds: elapsed),
            ),
            const SizedBox(height: 24),
            ControlBar(isRunning: running, onToggle: _toggle, onReset: _reset, currentPage: 2, totalPages: 3),
          ],
        ),
      ),
    );
  }
}
