import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 12개(5분 단위) 짧은 눈금을 그림
class TicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;
    final tickRadius = r * 0.78;

    final paint = Paint()
      ..color = const Color(0xFF9AA4B2)
      ..strokeWidth = 2;

    const sections = 12;
    for (int i = 0; i < sections; i++) {
      final angle = (-math.pi / 2) + (2 * math.pi * i / sections); // 12시 기준
      final p1 = Offset(c.dx + tickRadius * math.cos(angle), c.dy + tickRadius * math.sin(angle));
      final p2 = Offset(c.dx + (tickRadius - 12) * math.cos(angle), c.dy + (tickRadius - 12) * math.sin(angle));
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TicksPainter oldDelegate) => false; // 정적
}
