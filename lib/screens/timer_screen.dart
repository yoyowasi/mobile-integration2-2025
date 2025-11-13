import 'dart:async';
import 'package:flutter/material.dart';
import '../features/stats/stats_screen.dart';
import '../features/timer/data/session_store.dart';
import '../features/timer/data/session_model.dart';
import '../widgets/dialogs/quick_log_dialog.dart';
import '../widgets/dial/dial_canvas.dart';
import '../widgets/controls/control_bar.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final SessionStore _sessionStore = SessionStore();

  Timer? _ticker;
  int elapsed = 0;
  bool running = false;
  String _mode = 'custom';

  int _customMinutes = 25;
  int _autoMinutes = 25;
  DateTime? _startedAt;

  int get _currentTotalMinutes =>
      _mode == 'auto' ? _autoMinutes : _customMinutes;

  @override
  void initState() {
    super.initState();
    _loadAutoFromHistory();
  }

  Future<void> _loadAutoFromHistory() async {
    final optimal = await _sessionStore.calculateOptimalMinutes();
    if (!mounted) return;
    setState(() {
      _autoMinutes = optimal;
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

      if (elapsed >= _currentTotalMinutes * 60) {
        _finishSession(completed: true);
        _resetState();
      }
    });
  }

  void _pause() async {
    if (!running) return;
    _ticker?.cancel();
    setState(() => running = false);

    // Quick Log 다이얼로그 표시
    String? reason = await QuickLogDialog.show(context);

    // 중단 이유와 함께 기록
    _finishSession(completed: false, quitReason: reason);
  }

  void _toggle() => running ? _pause() : _start();

  Future<void> _finishSession({
    required bool completed,
    String? quitReason,
  }) async {
    if (elapsed <= 0) return;

    final start =
        _startedAt ?? DateTime.now().subtract(Duration(seconds: elapsed));
    final end = DateTime.now();

    final session = SessionModel(
      startedAt: start,
      endedAt: end,
      durationSec: elapsed,
      mode: _mode,
      completed: completed,
      quitReason: quitReason,
    );
    await _sessionStore.append(session);

    // 완료 시 Adaptive 알고리즘 적용
    if (completed) {
      final optimal = await _sessionStore.calculateOptimalMinutes();
      if (!mounted) return;
      setState(() {
        _autoMinutes = optimal;
      });
    }
  }

  void _resetState() {
    _ticker?.cancel();
    setState(() {
      elapsed = 0;
      running = false;
      _startedAt = null;
    });
  }

  void _handleModeChange(bool isAuto) {
    if (running) {
      _pause();
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
    final showCenterBadge = !isAutoMode;
    final showNumbers = !isAutoMode;
    final showTicks = !isAutoMode;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
        ],
      ),
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
