import 'dart:io';
import 'package:flutter/material.dart';

class PermissionsService {
  Future<void> requestPostNotificationsIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;
    // Starter: show info dialog. You can integrate `permission_handler` later.
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림 권한 안내'),
        content: const Text('Android 13+에서 알림 표시를 위해 권한이 필요할 수 있어요. 설정에서 허용해 주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          )
        ],
      ),
    );
  }
}
