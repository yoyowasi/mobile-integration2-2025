// lib/features/timer/data/session_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_model.dart';

class SessionStore {
  static const _key = 'timer_sessions_v1';

  Future<List<SessionModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <SessionModel>[];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SessionModel.fromJson(
      Map<String, dynamic>.from(e as Map),
    ))
        .toList();
  }

  Future<void> append(SessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAll();

    current.add(session);

    // 너무 많아지면 앞부분 잘라내기 (예: 200개까지만 유지)
    const maxSessions = 200;
    final trimmed = current.length > maxSessions
        ? current.sublist(current.length - maxSessions)
        : current;

    final raw = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  /// 최근 "완료된" 세션의 분 단위 길이 반환
  /// (없으면 null)
  Future<int?> getLastCompletedMinutes() async {
    final sessions = await loadAll();
    for (var i = sessions.length - 1; i >= 0; i--) {
      final s = sessions[i];
      if (s.completed && s.durationSec > 0) {
        return (s.durationSec / 60).round();
      }
    }
    return null;
  }
}
