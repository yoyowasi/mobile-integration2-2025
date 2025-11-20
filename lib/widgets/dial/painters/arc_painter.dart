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

    const maxMinutes = 60;
    final maxSeconds = maxMinutes * 60;

    final remainRatio = (remainSeconds / maxSeconds).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path(); // moveTo는 아래 로직에 따라 필요 없을 수 있음

    // 🔥 [수정된 부분] 비율이 1.0(60분)이면 꽉 찬 원을 그림
    if (remainRatio >= 1.0) {
      path.addOval(rect); // 그냥 원을 추가
    } else if (remainRatio > 0.0) {
      // 1.0 미만일 때만 기존 부채꼴 로직 실행
      path.moveTo(c.dx, c.dy); // 중심으로 이동
      const start = -math.pi / 2;
      final sweep = 2 * math.pi * remainRatio;
      path.arcTo(rect, start, sweep, false);
      path.lineTo(c.dx, c.dy); // 중심으로 돌아옴
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
