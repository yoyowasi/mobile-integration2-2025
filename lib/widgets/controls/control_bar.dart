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
        // 시작/중단 버튼 (수정)
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
              Icon(isRunning ? Icons.stop : Icons.play_arrow, size: 28), // 🔥 pause → stop
              const SizedBox(width: 8),
              Text(
                isRunning ? '중단' : '시작', // 🔥 일시정지 → 중단
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
                enabled: canUseAutoMode,
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE74D50)
              : enabled
              ? Colors.transparent
              : Colors.grey.shade100,
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
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : enabled
                    ? Colors.black87
                    : Colors.grey.shade400,
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
