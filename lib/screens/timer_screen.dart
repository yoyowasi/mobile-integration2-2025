import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/notify_service.dart';
import '../features/timer/data/session_store.dart';
import '../features/timer/data/session_model.dart';
import '../providers/settings_provider.dart';
import '../widgets/controls/control_bar.dart';
import '../widgets/dialogs/quick_log_dialog.dart';
import '../widgets/dial/dial_canvas.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final SessionStore _sessionStore = SessionStore();

  Timer? _ticker;
  int elapsed = 0;
  bool running = false;
  String _mode = 'custom';

  int _autoMinutes = 25; // 초기값은 25로 두되, Auto 모드 진입 조건(_canUseAutoMode)에 의해 보호됨
  int _sessionCount = 0;
  DateTime? _startedAt;

  bool get _canUseAutoMode => _sessionCount >= 5;

  int get _currentTotalMinutes {
    final settings = ref.read(settingsProvider);
    return _mode == 'auto' ? _autoMinutes : settings.defaultMinutes;
  }

  @override
  void initState() {
    super.initState();
    _loadAutoFromHistory();
  }

  Future<void> _loadAutoFromHistory() async {
    final sessions = await _sessionStore.getRecentSessions(limit: 10);
    // 🔥 [수정] null 반환 가능성 처리
    final optimal = await _sessionStore.calculateOptimalMinutes();

    if (!mounted) return;
    setState(() {
      _sessionCount = sessions.length;
      // 데이터가 있어서 계산된 값이 있을 때만 업데이트
      if (optimal != null) {
        _autoMinutes = optimal;
      }
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

        // 🔥 알림 표시
        NotificationService().showCompletionNotification(
          minutes: _currentTotalMinutes,
          mode: _mode,
        );
      }
    });
  }


  void _pause() async {
    if (!running) return;
    _ticker?.cancel();
    setState(() => running = false);

    if (!mounted) return;
    String? reason = await QuickLogDialog.show(context);
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

    if (completed) {
      // 🔥 [수정] null 반환 가능성 처리
      final optimal = await _sessionStore.calculateOptimalMinutes();
      if (!mounted) return;
      setState(() {
        if (optimal != null) {
          _autoMinutes = optimal;
        }
        _sessionCount++;
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
    print('🔄 모드 변경: ${isAuto ? "Auto" : "Custom"}, 세션: $_sessionCount, 가능: $_canUseAutoMode');

    if (isAuto && !_canUseAutoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('학습을 위해 최소 5개의 세션이 필요해요\n현재: $_sessionCount개'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange.shade700,
        ),
      );

      if (_mode == 'auto') {
        setState(() {
          _mode = 'custom';
        });
      }
      return;
    }

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
        title: const Text(
          'Adaptive Pomodoro',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (isAutoMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_autoMinutes분',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!_canUseAutoMode && isAutoMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI 학습을 위해 최소 5개의 세션이 필요해요\n현재: $_sessionCount개',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAutoMode ? Colors.blue.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAutoMode ? Icons.auto_awesome : Icons.tune,
                        size: 18,
                        color: isAutoMode ? Colors.blue : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAutoMode
                              ? 'AI가 $_autoMinutes분으로 추천했어요'
                              : '원하는 시간을 직접 설정하세요',
                          style: TextStyle(
                            fontSize: 11,
                            color: isAutoMode ? Colors.blue.shade900 : Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 4),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: PomodoroDial(
                  totalMinutes: _currentTotalMinutes,
                  elapsedSeconds: elapsed,
                  showCenterBadge: showCenterBadge,
                  showNumbers: showNumbers,
                  showTicks: showTicks,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ControlBar(
              isRunning: running,
              onToggle: _toggle,
              isAutoMode: isAutoMode,
              canUseAutoMode: _canUseAutoMode,
              onModeChanged: _handleModeChange,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}