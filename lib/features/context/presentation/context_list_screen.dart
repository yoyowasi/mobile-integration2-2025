import 'package:flutter/material.dart';

class ContextListScreen extends StatelessWidget {
  const ContextListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('컨텍스트')),
      body: const Center(
        child: Text('프리셋 목록 (추가/수정 예정)'),
      ),
    );
  }
}
