import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'painters/numbers_painter.dart';
import 'painters/ticks_painter.dart';
import 'painters/arc_painter.dart';
import 'center_badge.dart';
import 'dial_container.dart';

/// 다이얼을 구성하는 레이아웃(스택) – 페인터 레이어들을 얹음
class PomodoroDial extends StatelessWidget {
  const PomodoroDial({
    super.key,
    required this.totalMinutes,
    required this.elapsedSeconds,
    this.arcColor = const Color(0xFFE74D50),
    required this.showCenterBadge,
    required this.showNumbers,
    required this.showTicks,
  });

  final int totalMinutes;
  final int elapsedSeconds;
  final Color arcColor;
  final bool showCenterBadge;
  final bool showNumbers;
  final bool showTicks;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = math.max(1, totalMinutes * 60);
    final clamped = elapsedSeconds.clamp(0, totalSeconds);
    final remainSeconds = totalSeconds - clamped;
    final remainMinutes = (remainSeconds / 60).ceil();

    final List<Widget> children = [];

    // 눈금 레이어 (showTicks가 true일 때만)
    if (showTicks) {
      children.add(
        CustomPaint(
          painter: TicksPainter(),
          child: const SizedBox.expand(),
        ),
      );
    }

    // 숫자 레이어 (showNumbers가 true일 때만)
    if (showNumbers) {
      children.add(
        CustomPaint(
          painter: NumbersPainter(),
          child: const SizedBox.expand(),
        ),
      );
    }

    // 남은 시간 원호 레이어 (항상 표시)
    children.add(
      CustomPaint(
        painter: ArcPainter(
          totalMinutes: totalMinutes,
          remainSeconds: remainSeconds,
          color: arcColor,
        ),
        child: const SizedBox.expand(),
      ),
    );

    // 중앙 배지 (showCenterBadge가 true일 때만)
    if (showCenterBadge) {
      children.add(
        CenterBadge(
          remainMinutes: remainMinutes.clamp(0, totalMinutes),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: DialContainer(
        child: Stack(
          alignment: Alignment.center,
          children: children,
        ),
      ),
    );
  }
}
