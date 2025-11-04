import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/tostore_service.dart';

/// ToStoreService 인스턴스 제공
final toStoreServiceProvider = Provider<ToStoreService>((ref) {
  final svc = ToStoreService();
  // 앱 시작 시 1회 초기화
  // (Future를 기다려야 하면 main에서 await 해도 됩니다)
  svc.init();
  return svc;
});

/// 설정 모델
class SettingsModel {
  final String mode; // 'auto' | 'custom'
  final int focus;   // 집중 시간
  final int brk;     // 휴식 시간
  final bool notify; // 알림 여부

  SettingsModel({
    required this.mode,
    required this.focus,
    required this.brk,
    required this.notify,
  });
}

/// 설정 로드
final settingsProvider = FutureProvider<SettingsModel>((ref) async {
  final s = ref.read(toStoreServiceProvider);
  return SettingsModel(
    mode: await s.getMode(),
    focus: await s.getFocusMinutes(),
    brk: await s.getBreakMinutes(),
    notify: await s.isNotifyEnabled(),
  );
});
