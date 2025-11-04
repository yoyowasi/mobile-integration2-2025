import 'package:flutter/material.dart';
import 'play_pause_button.dart';
import 'reset_button.dart';
import 'page_dots.dart';

/// 하단 컨트롤(리셋, 재생/일시정지, 페이지 점)
class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
    this.currentPage = 1,
    this.totalPages = 3,
  });

  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ResetButton(onPressed: onReset),
          PlayPauseButton(isRunning: isRunning, onPressed: onToggle),
          PageDots(current: currentPage, total: totalPages),
        ],
      ),
    );
  }
}
