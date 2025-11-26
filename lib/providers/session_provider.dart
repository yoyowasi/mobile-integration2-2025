import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/timer/data/session_model.dart';
import '../features/timer/data/session_store.dart';

// 세션 리스트를 관리하고 변경사항을 알리는 Provider
final sessionListProvider = AsyncNotifierProvider<SessionListNotifier, List<SessionModel>>(() {
  return SessionListNotifier();
});

class SessionListNotifier extends AsyncNotifier<List<SessionModel>> {
  final _store = SessionStore();

  @override
  Future<List<SessionModel>> build() async {
    return _fetchSessions();
  }

  // 데이터 불러오기
  Future<List<SessionModel>> _fetchSessions() async {
    final sessions = await _store.getAll();
    // 최신순 정렬
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  // 세션 추가 (타이머 종료 시 호출)
  Future<void> addSession(SessionModel session) async {
    state = const AsyncValue.loading(); // 로딩 상태로 변경
    await _store.append(session);       // 저장소에 저장
    state = await AsyncValue.guard(() => _fetchSessions()); // 리스트 새로고침 및 알림
  }

  // 세션 삭제 (기록 화면에서 호출)
  Future<void> deleteSession(SessionModel session) async {
    state = const AsyncValue.loading();

    // 기존 SessionStore에는 삭제 기능이 없어 여기서 직접 처리 로직 구현
    final allSessions = await _store.getAll();
    allSessions.removeWhere((s) =>
    s.startedAt == session.startedAt && s.endedAt == session.endedAt
    );

    // 덮어쓰기
    await _store.clear();
    for (var s in allSessions) {
      await _store.append(s);
    }

    state = await AsyncValue.guard(() => _fetchSessions());
  }
}