// lib/screens/timer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/dial/dial_canvas.dart';
import '../widgets/controls/control_bar.dart';

/// 단순 동작 확인용 데모 스크린 (Custom/Auto 모드 기능 추가)
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final int totalMinutes = 25; // 기본 25분
  Timer? _ticker;
  int elapsed = 0; // 경과 초
  bool running = false;
  String _mode = 'custom'; // 'custom' | 'auto' - 기본값은 'custom'

  void _start() {
    if (running) return;
    setState(() => running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        elapsed++;
        if (elapsed >= totalMinutes * 60) {
          _resetState(); // 완료 시 리셋
        }
      });
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => running = false);
  }

  void _toggle() => running ? _pause() : _start();

  // 타이머 완료/리셋 공용
  void _resetState() {
    _ticker?.cancel();
    setState(() {
      elapsed = 0;
      running = false;
    });
  }

  // 모드 변경: 실행 중이면 멈추고 모드만 변경
  void _handleModeChange(bool isAuto) {
    if (running) {
      _pause();
    }
    setState(() {
      _mode = isAuto ? 'auto' : 'custom';
      // 필요 시 모드 전환 시 초기화하려면 아래 주석 해제
      // elapsed = 0;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAutoMode = _mode == 'auto';
    final showCenterBadge = !isAutoMode; // 오토 모드일 때 중앙 배지 숨김

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: PomodoroDial(
                totalMinutes: totalMinutes,
                elapsedSeconds: elapsed,
                showCenterBadge: showCenterBadge,
              ),
            ),
            ControlBar(
              isRunning: running,
              onToggle: _toggle,
              isAutoMode: isAutoMode,
              onModeChanged: _handleModeChange,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
