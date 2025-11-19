import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 남은 시간 비율에 따라 부채꼴(원호)을 채움 (60분 기준)
class ArcPainter extends CustomPainter {
  ArcPainter({
    required this.totalMinutes,
    required this.remainSeconds,
    required this.color,
  });

  final int totalMinutes;
  final int remainSeconds;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;
    final arcR = r * 0.72;
    final rect = Rect.fromCircle(center: c, radius: arcR);

    // 🔥 60분 기준으로 계산! (눈금과 맞추기 위해)
    const maxMinutes = 60;
    final maxSeconds = maxMinutes * 60;

    // 남은 시간을 60분 기준 비율로 계산
    final remainRatio = (remainSeconds / maxSeconds).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(c.dx, c.dy);

    // 비율이 0보다 클 때만 부채꼴을 그림
    if (remainRatio > 0.0) {
      const start = -math.pi / 2; // 12시 시작 (0분 위치)
      final sweep = 2 * math.pi * remainRatio; // 60분 기준 남은 시간
      path.arcTo(rect, start, sweep, false);
      path.lineTo(c.dx, c.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.remainSeconds != remainSeconds ||
        oldDelegate.totalMinutes != totalMinutes ||
        oldDelegate.color != color;
  }
}
