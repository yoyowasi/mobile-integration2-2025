import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'painters/ticks_painter.dart';
import 'painters/numbers_painter.dart';
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
    required this.showCenterBadge, // 중앙 배지 표시 여부
    this.showNumbers = true,       // 👈 숫자(눈금 옆 라벨) 표시 여부
    this.showTicks = true,
  });

  final int totalMinutes;      // 전체 분 (예: 25)
  final int elapsedSeconds;    // 경과 초
  final Color arcColor;        // 원호 색
  final bool showCenterBadge;  // 중앙 배지 표시 여부
  final bool showNumbers;      // 👈 눈금 옆 숫자 표시 여부
  final bool showTicks;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = math.max(1, totalMinutes * 60);
    final clamped = elapsedSeconds.clamp(0, totalSeconds);
    final remainSeconds = totalSeconds - clamped;
    final remainMinutes = (remainSeconds / 60).ceil();

    final List<Widget> children = [
      // 눈금 레이어
      if (showTicks)
        CustomPaint(
          painter: TicksPainter(),
          child: const SizedBox.expand(),
        ),

      // 숫자 레이어 (옵션)
      if (showNumbers)
        CustomPaint(
          painter: NumbersPainter(),
          child: const SizedBox.expand(),
        ),

      // 남은 시간 원호 레이어
      CustomPaint(
        painter: ArcPainter(
          totalMinutes: totalMinutes,
          remainSeconds: remainSeconds,
          color: arcColor,
          isAutoMode: !showCenterBadge
        ),
        child: const SizedBox.expand(),
      ),
    ];

    // showCenterBadge가 true일 때만 CenterBadge를 추가
    if (showCenterBadge) {
      children.add(
        CenterBadge(
          remainMinutes: remainMinutes.clamp(0, totalMinutes),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1, // 정사각형
      child: DialContainer(
        child: Stack(
          alignment: Alignment.center,
          children: children,
        ),
      ),
    );
  }
}
