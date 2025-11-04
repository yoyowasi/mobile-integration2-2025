import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.isRunning, required this.onPressed});
  final bool isRunning;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE74D50),
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 76,
          height: 76,
          child: Center(
            child: Icon(isRunning ? LucideIcons.pause : LucideIcons.play, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
