import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 남은 시간 비율에 따라 부채꼴(또는 도넛형 원호)을 채움
class ArcPainter extends CustomPainter {
  ArcPainter({
    required this.totalMinutes,
    required this.remainSeconds,
    required this.color,
    this.isAutoMode = false, // 오토 모드 여부
  });

  final int totalMinutes;
  final int remainSeconds;
  final Color color;
  final bool isAutoMode;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;

    final totalSeconds = math.max(1, totalMinutes * 60);
    final remainRatio = (remainSeconds / totalSeconds).clamp(0.0, 1.0);

    // 🔹 오토 모드: 도넛형 큰 원호(구멍 뚫린 원)
    if (isAutoMode) {
      if (remainRatio <= 0.0) return; // 남은 비율 없으면 안 그림

      // 원을 조금 더 크게
      final arcR = r * 0.9; // 기본 0.72보다 큼
      final rect = Rect.fromCircle(center: c, radius: arcR);

      // 굵은 stroke로 도넛 느낌
      final strokeWidth = arcR * 0.6; // 반지름에 비례해서 굵게
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      const start = -math.pi / 2;              // 12시 기준
      final sweep = 2 * math.pi * remainRatio; // 남은 비율만큼

      canvas.drawArc(rect, start, sweep, false, paint);
      return;
    }

    // 🔹 커스텀 모드: 기존처럼 "부채꼴(파이)"로 채우기
    final arcR = r * 0.72;
    final rect = Rect.fromCircle(center: c, radius: arcR);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(c.dx, c.dy); // 중심점에서 시작

    // 비율이 1.0(360도)에 가까우면 꽉 찬 원
    if (remainRatio > 0.9999) {
      path.addOval(rect);
    }
    // 0 < 비율 < 1 이면 부채꼴
    else if (remainRatio > 0.0) {
      const start = -math.pi / 2;               // 12시 시작
      final sweep = 2 * math.pi * remainRatio;  // 남은 비율만큼
      path.arcTo(rect, start, sweep, false);    // 부채꼴 호
    }
    // remainRatio == 0이면 아무것도 안 그림

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter old) =>
      old.remainSeconds != remainSeconds ||
          old.totalMinutes != totalMinutes ||
          old.color != color ||
          old.isAutoMode != isAutoMode;
}
