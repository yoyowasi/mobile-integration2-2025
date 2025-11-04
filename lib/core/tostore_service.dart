import 'dart:convert';
import 'package:tostore/tostore.dart';

/// ToStore를 이용해 설정/세션 데이터를 보관하는 서비스
/// - 주의: ToStore는 사용 전 initialize가 필요함
class ToStoreService {
  // 단일 인스턴스(앱 전역에서 재사용)
  final ToStore _db = ToStore();

  ToStoreService() {
    // 생성자에서 비동기 호출은 못 하니, 외부에서 init()을 꼭 한번 호출하세요.
  }

  /// 앱 시작 시 1회 호출 (예: main()에서)
  Future<void> init() async {
    await _db.initialize(); // 스토리지 초기화 (필수) :contentReference[oaicite:2]{index=2}
  }

  // ---------------- [설정 - Key/Value] ----------------

  /// 타이머 모드 저장 ("auto" 또는 "custom")
  Future<void> setMode(String mode) => _db.setValue('timer.mode', mode);

  /// 타이머 모드 조회 (기본값: 'auto')
  Future<String> getMode() async =>
      (await _db.getValue('timer.mode')) as String? ?? 'auto';

  /// 집중 시간(분) 저장
  Future<void> setFocusMinutes(int value) =>
      _db.setValue('timer.focus_minutes', value);

  /// 집중 시간(분) 조회 (기본값: 25)
  Future<int> getFocusMinutes() async =>
      (await _db.getValue('timer.focus_minutes')) as int? ?? 25;

  /// 휴식 시간(분) 저장
  Future<void> setBreakMinutes(int value) =>
      _db.setValue('timer.break_minutes', value);

  /// 휴식 시간(분) 조회 (기본값: 5)
  Future<int> getBreakMinutes() async =>
      (await _db.getValue('timer.break_minutes')) as int? ?? 5;

  /// 알림 on/off 저장
  Future<void> setNotifyEnabled(bool on) =>
      _db.setValue('notify.enabled', on);

  /// 알림 on/off 조회 (기본값: true)
  Future<bool> isNotifyEnabled() async =>
      (await _db.getValue('notify.enabled')) as bool? ?? true;

  // ---------------- [세션 - JSON 일괄 저장] ----------------

  /// 세션 리스트(JSON 배열 문자열) 저장
  Future<void> saveSessionsJson(List<Map<String, dynamic>> list) async {
    final json = jsonEncode(list);
    await _db.setValue('sessions.v1.json', json);
  }

  /// 세션 리스트 불러오기
  Future<List<Map<String, dynamic>>> loadSessionsJson() async {
    final raw = await _db.getValue('sessions.v1.json') as String?;
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
