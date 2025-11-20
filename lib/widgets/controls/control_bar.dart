import 'package:flutter/material.dart';

class ControlBar extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onToggle;
  final bool isAutoMode;
  final bool canUseAutoMode;
  final Function(bool) onModeChanged;

  const ControlBar({
    super.key,
    required this.isRunning,
    required this.onToggle,
    required this.isAutoMode,
    required this.canUseAutoMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 시작/일시정지 버튼
        ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE74D50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 28),
              const SizedBox(width: 8),
              Text(
                isRunning ? '일시정지' : '시작',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Custom / Auto 토글
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                // ✅ [수정] withAlpha(26) -> withValues(alpha: 0.1)
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeButton(
                label: 'Custom',
                icon: Icons.tune,
                isSelected: !isAutoMode,
                enabled: true,
                onTap: () => onModeChanged(false),
              ),
              const SizedBox(width: 4),
              _buildModeButton(
                label: 'Auto',
                icon: Icons.auto_awesome,
                isSelected: isAutoMode,
                enabled: canUseAutoMode, // 스타일은 비활성(회색) 유지
                // ✅ [수정] 비활성 상태여도 클릭 이벤트는 항상 전달 (스낵바 띄우기 위해)
                onTap: () => onModeChanged(true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      // ✅ [수정] enabled 여부와 상관없이 탭 감지
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE74D50)
              : enabled
              ? Colors.transparent
              : Colors.grey.shade100, // 비활성일 때 회색 배경
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : enabled
                  ? Colors.black54
                  : Colors.grey.shade400, // 비활성일 때 회색 아이콘
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : enabled
                    ? Colors.black87
                    : Colors.grey.shade400, // 비활성일 때 회색 텍스트
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}