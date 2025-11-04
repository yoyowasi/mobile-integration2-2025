import 'package:flutter/material.dart';

/// 다이얼을 감싸는 둥근 사각형 컨테이너
class DialContainer extends StatelessWidget {
  const DialContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),          // 내부 연회색
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF101C2A), width: 18), // 남색 테두리
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: child,
    );
  }
}
