import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/timer/data/session_model.dart';
import '../features/timer/data/session_store.dart';

// 전체 세션 리스트를 관리하는 Provider
final sessionListProvider = AsyncNotifierProvider<SessionListNotifier, List<SessionModel>>(() {
  return SessionListNotifier();
});

class SessionListNotifier extends AsyncNotifier<List<SessionModel>> {
  final _store = SessionStore();

  @override
  Future<List<SessionModel>> build() async {
    return _fetchSessions();
  }

  // 데이터 불러오기 (최신순 정렬)
  Future<List<SessionModel>> _fetchSessions() async {
    final sessions = await _store.getAll();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  // 세션 추가 (타이머 종료 시 호출)
  Future<void> addSession(SessionModel session) async {
    state = const AsyncValue.loading();
    await _store.append(session);
    state = await AsyncValue.guard(() => _fetchSessions());
  }

  // 세션 삭제 (기록 화면에서 스와이프로 삭제 시 호출)
  Future<void> deleteSession(SessionModel session) async {
    state = const AsyncValue.loading();

    final allSessions = await _store.getAll();
    allSessions.removeWhere((s) =>
    s.startedAt == session.startedAt && s.endedAt == session.endedAt
    );

    await _store.clear();
    for (var s in allSessions) {
      await _store.append(s);
    }

    state = await AsyncValue.guard(() => _fetchSessions());
  }

  // [추가된 메서드] 전체 삭제 (설정 화면에서 호출)
  Future<void> clearAll() async {
    state = const AsyncValue.loading();
    await _store.clear(); // 저장소 비우기
    state = const AsyncValue.data([]); // 빈 리스트로 상태 갱신 -> 모든 화면에 알림!
  }
}