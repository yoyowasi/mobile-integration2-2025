import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../providers/settings_provider.dart';
import 'session_model.dart';

/// 세션 리스트 상태를 관리하는 Notifier
final sessionListProvider =
StateNotifierProvider<SessionListNotifier, List<PomodoroSession>>(
      (ref) => SessionListNotifier(ref),
);

class SessionListNotifier extends StateNotifier<List<PomodoroSession>> {
  SessionListNotifier(this.ref) : super([]);
  final Ref ref; // ← Reader 대신 Ref 사용 (Riverpod v2)

  /// ToStore에서 세션 목록 로드
  Future<void> loadFromToStore() async {
    final ts = ref.read(toStoreServiceProvider);
    final jsonList = await ts.loadSessionsJson();
    state = jsonList.map((e) => PomodoroSession.fromJson(e)).toList();
  }

  /// 세션 추가 + 저장
  Future<void> addAndPersist(PomodoroSession s) async {
    state = [...state, s];
    await _persist();
  }

  /// 세션 갱신 + 저장
  Future<void> updateAndPersist(PomodoroSession s) async {
    state = [
      for (final x in state) if (x.id == s.id) s else x,
    ];
    await _persist();
  }

  /// 현재 state를 ToStore에 JSON으로 반영
  Future<void> _persist() async {
    final ts = ref.read(toStoreServiceProvider);
    await ts.saveSessionsJson(state.map((e) => e.toJson()).toList());
  }
}
