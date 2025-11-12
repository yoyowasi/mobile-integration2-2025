// lib/screens/main_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_integration2_2025/core/tostore_service.dart';

import '../widgets/timer/timer_controls.dart';
import '../widgets/timer/timer_display.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int kMaxSec = 55; // 0 ~ 55 (inclusive)
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  String _mode = 'focus'; // 'focus' | 'break'

  void _onTick(Timer _) async {
    if (!_isRunning) return;
    if (_seconds < kMaxSec) {
      setState(() => _seconds += 1);
    } else {
      await _completeSession(completed: true);
    }
  }

  Future<void> _start() async {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer ??= Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  Future<void> _stop() async {
    if (!_isRunning) return;
    await _completeSession(completed: false);
  }

  Future<void> _reset() async {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _seconds = 0;
    });
  }

  Future<void> _completeSession({required bool completed}) async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    final durationSec = _seconds;
    setState(() {});

    await ToStoreService.appendSessionLog(
      mode: _mode,
      durationSec: durationSec,
      completed: completed,
      endedAt: DateTime.now(),
    );

    if (!mounted) return;
    final msg = completed
        ? "세션 완료 ($_mode) - $_seconds초"
        : "세션 중단 ($_mode) - $_seconds초";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    setState(() {
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF2FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'focus', label: Text('집중')),
                      ButtonSegment(value: 'break', label: Text('휴식')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) {
                      if (_isRunning) return;
                      setState(() => _mode = s.first);
                    },
                  ),
                ],
              ),
              const Spacer(),
              // named parameter: timeLeft 로 통일
              TimerDisplay(timeLeft: _seconds),
              const SizedBox(height: 12),
              const Text(
                "0에서 55까지 카운트업",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF263FA9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TimerControls(
                isRunning: _isRunning,
                onStart: _start,
                onStop: _stop,
                onReset: _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
