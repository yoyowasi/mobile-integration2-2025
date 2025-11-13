// lib/screens/timer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_integration2_2025/features/timer/data/session_store.dart';
import 'package:mobile_integration2_2025/features/timer/data/session_model.dart';

import '../services/notify_service.dart';
import '../widgets/dial/dial_canvas.dart';
import '../widgets/controls/control_bar.dart';
import '../widgets/dialogs/quick_log_dialog.dart';

/// 단순 동작 확인용 데모 스크린 (Custom/Auto 모드 + 최근 기록 기반 오토)
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final SessionStore _sessionStore = SessionStore();
  final NotificationService _notificationService = NotificationService();

  Timer? _ticker;
  int elapsed = 0; // 경과 초
  bool running = false;
  String _mode = 'custom'; // 'custom' | 'auto'

  int _customMinutes = 1;  // 커스텀 기준 시간
  int _autoMinutes = 25;    // 오토 모드 기준 시간 (최근 기록에서 갱신)
  DateTime? _startedAt;     // 실제 시작 시간 (기록용)

  int get _currentTotalMinutes =>
      _mode == 'auto' ? _autoMinutes : _customMinutes;

  @override
  void initState() {
    super.initState();
    _loadAutoFromHistory();
  }

  Future<void> _loadAutoFromHistory() async {
    final last = await _sessionStore.getLastCompletedMinutes();
    if (!mounted) return;
    setState(() {
      // 최근 완료 세션이 있으면 그걸 오토 기준으로 사용
      // 없으면 기본값 25분
      _autoMinutes = last ?? 25;
    });
  }

  void _start() {
    if (running) return;
    _startedAt = DateTime.now();
    setState(() => running = true);

    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        elapsed++;
      });

      // 목표 시간 도달
      if (elapsed >= _currentTotalMinutes * 60) {
        _finishSession(completed: true);
        _showCompletionNotification(); // 알림 표시
        _resetState();
      }
    });
  }

  Future<void> _showCompletionNotification() async {
    await _notificationService.showTimerCompleteNotification(
      mode: _mode,
      minutes: _currentTotalMinutes,
    );
  }

  void _pause() async {  // async 추가!
    if (!running) return;
    _ticker?.cancel();
    setState(() => running = false);

    // Quick Log 다이얼로그 표시
    String? reason = await QuickLogDialog.show(context);

    // 중단 이유와 함께 기록
    _finishSession(completed: false, quitReason: reason);
  }


  void _toggle() => running ? _pause() : _start();

  Future<void> _finishSession({required bool completed, String? quitReason}) async {
    if (elapsed <= 0) return; // 아무것도 안 했으면 스킵

    final start =
        _startedAt ?? DateTime.now().subtract(Duration(seconds: elapsed));
    final end = DateTime.now();

    final session = SessionModel(
      startedAt: start,
      endedAt: end,
      durationSec: elapsed,
      mode: _mode,
      completed: completed,
    );
    await _sessionStore.append(session);

    // 완료된 세션이면 오토 기준 시간 갱신
    if (completed) {
      final last = await _sessionStore.getLastCompletedMinutes();
      if (!mounted) return;
      if (last != null) {
        setState(() {
          _autoMinutes = last;
        });
      }

    }
  }
  // 내부 상태 리셋 (화면/타이머 초기화)
  void _resetState() {
    _ticker?.cancel();
    setState(() {
      elapsed = 0;
      running = false;
      _startedAt = null;
    });
  }

  // 모드 변경 처리: 실행 중이면 멈추고 모드만 변경 + 경과시간 초기화
  void _handleModeChange(bool isAuto) {
    if (running) {
      _pause(); // 실행 중이면 멈추고 기록까지 남김
    }
    setState(() {
      _mode = isAuto ? 'auto' : 'custom';
      elapsed = 0;
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
    final showCenterBadge = !isAutoMode; // 오토 모드일 때 중앙 숫자 숨김 등
    final showNumbers = !isAutoMode;
    final showTicks = !isAutoMode;

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
                totalMinutes: _currentTotalMinutes,
                elapsedSeconds: elapsed,
                showCenterBadge: showCenterBadge,
                showNumbers: showNumbers,
                showTicks: showTicks,
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
