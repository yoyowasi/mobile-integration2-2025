import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 26,
      color: const Color(0xFF1D2A39),
      splashRadius: 26,
      icon: const Icon(LucideIcons.rotateCcw),
      tooltip: '리셋',
    );
  }
}
