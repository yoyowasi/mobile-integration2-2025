import 'package:flutter/material.dart';

/// 중앙의 남은 '분'을 보여주는 동그란 배지
class CenterBadge extends StatelessWidget {
  const CenterBadge({super.key, required this.remainMinutes});
  final int remainMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Text(
        '$remainMinutes',
        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w600, color: Color(0xFF1D2A39)),
      ),
    );
  }
}
