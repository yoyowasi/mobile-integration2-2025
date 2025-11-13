import 'package:flutter/material.dart';

class QuickLogDialog {
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '중단 원인',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(context, '스마트폰 사용', 'phone'),
            _buildOption(context, '피곤함', 'tired'),
            _buildOption(context, '배고픔/갈증', 'hunger'),
            _buildOption(context, '집중력 저하', 'distracted'),
            _buildOption(context, '기타', 'other'),
          ],
        ),
      ),
    );
  }

  static Widget _buildOption(
      BuildContext context,
      String label,
      String value,
      ) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        width: double.infinity,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
