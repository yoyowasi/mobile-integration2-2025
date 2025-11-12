import 'package:flutter/material.dart';
import 'play_pause_button.dart';
// ResetButton, PageDots 제거

/// 하단 컨트롤(재생/일시정지 버튼, 모드 스위치)
class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
    required this.isRunning,
    required this.onToggle,
    required this.isAutoMode, // 새 파라미터
    required this.onModeChanged, // 새 파라미터
  });

  final bool isRunning;
  final VoidCallback onToggle;
  final bool isAutoMode;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    // 모드 스위치 위젯
    final modeSwitch = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Custom', style: TextStyle(color: Color(0xFF1D2A39), fontSize: 14)),
        Switch(
          value: isAutoMode,
          onChanged: onModeChanged,
          activeThumbColor: const Color(0xFFE74D50),
        ),
        const Text('Auto', style: TextStyle(color: Color(0xFF1D2A39), fontSize: 14)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // 버튼 2개만 남겨 가운데 정렬
        children: [
          // 모드 스위치를 왼쪽 또는 중앙에 배치
          modeSwitch,
          // 재생/일시정지 버튼
          PlayPauseButton(isRunning: isRunning, onPressed: onToggle),
        ],
      ),
    );
  }
}