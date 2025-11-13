import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_model.dart';

class SessionStore {
  static const _key = 'timer_sessions_json_v1';

  Future<List<SessionModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => SessionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> append(SessionModel s) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAll();
    current.add(s);
    final raw = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<int?> getLastCompletedMinutes() async {
    final all = await loadAll();
    final completed = all.where((s) => s.completed).toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return (completed.first.durationSec / 60).round();
  }

  Future<List<SessionModel>> getRecentSessions({int limit = 10}) async {
    final all = await loadAll();
    all.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return all.take(limit).toList();
  }

  Future<List<SessionModel>> getWeeklySessions() async {
    final all = await loadAll();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return all.where((s) => s.endedAt.isAfter(weekAgo)).toList()
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));
  }

  Future<int> calculateOptimalMinutes() async {
    final recent = await getRecentSessions(limit: 10);
    if (recent.isEmpty) return 25;
    final completedCount = recent.where((s) => s.completed).length;
    final completionRate = completedCount / recent.length;
    final avgMinutes = recent
        .map((s) => s.durationSec / 60)
        .reduce((a, b) => a + b) / recent.length;

    int optimalMinutes;
    if (completionRate >= 0.8) {
      optimalMinutes = (avgMinutes + 5).round().clamp(15, 45);
    } else if (completionRate >= 0.5) {
      optimalMinutes = avgMinutes.round().clamp(15, 45);
    } else {
      optimalMinutes = (avgMinutes - 5).round().clamp(15, 45);
    }
    return optimalMinutes;
  }
}