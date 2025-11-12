// lib/widgets/timer_display.dart
import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int timeLeft; // 0 ~ 55
  const TimerDisplay({super.key, required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    return Text(
      "$timeLeft",
      style: const TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w800,
        color: Color(0xFF263FA9),
      ),
    );
  }
}
