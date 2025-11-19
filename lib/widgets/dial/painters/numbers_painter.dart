import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 0,5,10,...,55 숫자를 시계방향으로 배치 (뽀모도로 카운트다운)
class NumbersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;
    final textRadius = r * 0.88;
    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const sections = 12; // 12등분(5분 간격)

    for (int i = 0; i < sections; i++) {
      // 각도: 12시(-90도)에서 시작해 시계방향으로 배치
      final angle = (-math.pi / 2) + (2 * math.pi * i / sections);

      // 🍅 뽀모도로 방식: 12시=0, 1시=5, 2시=10, ..., 11시=55
      final label = (i * 5) % 60;

      tp.text = TextSpan(
        text: '$label',
        style: const TextStyle(
          color: Color(0xFF8B96A3),
          fontSize: 12,
          height: 1.0,
        ),
      );
      tp.layout();

      final x = c.dx + textRadius * math.cos(angle) - tp.width / 2;
      final y = c.dy + textRadius * math.sin(angle) - tp.height / 2;

      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant NumbersPainter oldDelegate) => false;
}
