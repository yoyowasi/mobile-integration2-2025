import 'dart:convert';
import 'package:mobile_integration2_2025/core/tostore_service.dart';

/// 타이머 세션 로컬 저장소 어댑터
/// - 내부 형식: List[Map[String, dynamic]] 를 JSON으로 직렬화
class SessionStore {
  final ToStoreService _store;
  static const String _key = 'timer_sessions_json';

  SessionStore(this._store);

  /// 세션 목록 로드(없으면 빈 리스트)
  Future<List<Map<String, dynamic>>> load() async {
    final raw = await _store.loadSessionsJson();
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// 세션 목록 저장
  Future<void> save(List<Map<String, dynamic>> sessions) async {
    final raw = jsonEncode(sessions);
    await _store.saveSessionsJson(raw);
  }

  /// 필요 시 개별 삭제 등 확장 가능
  Future<void> clear() async {
    await _store.remove(_key);
  }
}
