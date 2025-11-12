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
  int elapsed = 0;             // 경과 초
  bool running = false;
  String _mode = 'custom'; // 'custom' | 'auto' - 기본값은 'custom'으로 설정

  void _start() {
    if (running) return;
    setState(() => running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        elapsed++;
        if (elapsed >= totalMinutes * 60) {
          // 타이머 완료 시 리셋
          _resetState();
        }
      });
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => running = false);
  }

  void _toggle() => running ? _pause() : _start();

  // 타이머 완료 시 내부 상태 리셋 함수
  void _resetState() {
    _ticker?.cancel();
    setState(() {
      elapsed = 0;
      running = false;
    });
  }

  // 모드 변경 처리: 타이머를 멈추고 모드만 변경합니다.
  void _handleModeChange(bool isAuto) {
    if (running) {
      _pause(); // 타이머가 실행 중이면 멈춥니다.
    }
    setState(() {
      _mode = isAuto ? 'auto' : 'custom'; // 모드만 변경
    });
  }


  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 오토 모드 여부
    final isAutoMode = _mode == 'auto';
    // 오토 모드일 때 가운데 숫자(CenterBadge)를 숨김
    final showCenterBadge = !isAutoMode;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          // [수정] MainAxisAlignment.spaceBetween를 사용하여 위젯을 위아래로 분산 배치
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 28), // 상단 여백

            // [수정] Expanded 제거 -> PomodoroDial이 AspectRatio(1)에 따라 정사각형 유지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: PomodoroDial(
                totalMinutes: totalMinutes,
                elapsedSeconds: elapsed,
                showCenterBadge: showCenterBadge, // CenterBadge 표시 여부 전달
              ),
            ),

            // ControlBar: 모드 스위치와 재생/일시정지 버튼 포함
            ControlBar(
              isRunning: running,
              onToggle: _toggle,
              isAutoMode: isAutoMode, // 모드 상태 전달
              onModeChanged: _handleModeChange, // 모드 변경 콜백 전달
            ),

            const SizedBox(height: 24), // 하단 여백
          ],
        ),
      ),
    );
  }
}