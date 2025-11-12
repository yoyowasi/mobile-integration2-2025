// lib/providers/settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/tostore_service.dart';

final toStoreServiceProvider = Provider<ToStoreService>((ref) {
  return const ToStoreService();
});

class SettingsModel {
  final String mode; // 'auto' | 'custom'
  final int focus;   // 분
  final int brk;     // 분
  final bool notify;

  const SettingsModel({
    required this.mode,
    required this.focus,
    required this.brk,
    required this.notify,
  });
}

final settingsProvider = FutureProvider<SettingsModel>((ref) async {
  final s = ref.read(toStoreServiceProvider);
  return SettingsModel(
    mode: await s.getMode(),
    focus: await s.getFocusMinutes(),
    brk: await s.getBreakMinutes(),
    notify: await s.isNotifyEnabled(),
  );
});
