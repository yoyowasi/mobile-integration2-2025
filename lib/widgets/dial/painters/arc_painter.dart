import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 남은 시간 비율에 따라 부채꼴(원호)을 채움
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

    final totalSeconds = math.max(1, totalMinutes * 60);
    final remainRatio = (remainSeconds / totalSeconds).clamp(0.0, 1.0);

    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()..moveTo(c.dx, c.dy); // 중심점에서 시작

    // [수정] 비율이 1.0(360도)에 가까우면 꽉 찬 원을 그림
    if (remainRatio > 0.9999) {
      path.addOval(rect);
    }
    // [수정] 비율이 0보다 클 때만 부채꼴을 그림
    else if (remainRatio > 0.0) {
      const start = -math.pi / 2;                     // 12시 시작
      final sweep = 2 * math.pi * remainRatio;        // 남은 비율만큼
      path.arcTo(rect, start, sweep, false); // 부채꼴 호 그리기
    }
    // remainRatio가 0이면(타이머 종료) path가 비어있게 됨

    path.close(); // 경로 닫기 (중심점으로)

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter old) =>
      old.remainSeconds != remainSeconds ||
          old.totalMinutes != totalMinutes ||
          old.color != color;
}