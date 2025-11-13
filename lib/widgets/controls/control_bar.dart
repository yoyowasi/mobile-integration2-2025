import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'play_pause_button.dart';

/// 하단 컨트롤(재생/일시정지 버튼, 모드 스위치)
class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
    required this.isRunning,
    required this.onToggle,
    required this.isAutoMode,
    required this.onModeChanged,
  });

  final bool isRunning;
  final VoidCallback onToggle;
  final bool isAutoMode;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 모드 스위치
          _buildModeSwitch(),
          // 재생/일시정지 버튼
          PlayPauseButton(isRunning: isRunning, onPressed: onToggle),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeChip(
            label: 'Custom',
            isActive: !isAutoMode,
            onTap: () {
              HapticFeedback.lightImpact();
              onModeChanged(false);
            },
          ),
          const SizedBox(width: 4),
          _buildModeChip(
            label: 'Auto',
            isActive: isAutoMode,
            onTap: () {
              HapticFeedback.lightImpact();
              onModeChanged(true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE74D50) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
