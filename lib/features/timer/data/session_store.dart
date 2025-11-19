import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_model.dart';

class SessionStore {
  static const _key = 'sessions';

  Future<void> append(SessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.add(session);
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<List<SessionModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null) return [];
    final List<dynamic> decoded = jsonDecode(str);
    return decoded.map((e) => SessionModel.fromJson(e)).toList();
  }

  Future<List<SessionModel>> getRecentSessions({int limit = 10}) async {
    final all = await getAll();
    return all.reversed.take(limit).toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // 🔥 === 통계용 메서드 추가 ===

  /// 주간 데이터 (최근 7일)
  Future<Map<String, double>> getWeeklyData() async {
    final all = await getAll();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekSessions = all.where((s) => s.startedAt.isAfter(weekAgo)).toList();

    // 요일별 집중 시간 (분 단위)
    final Map<String, double> dayData = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (var session in weekSessions) {
      final weekday = session.startedAt.weekday; // 1=Monday, 7=Sunday
      final dayKey = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
      dayData[dayKey] = (dayData[dayKey] ?? 0) + (session.durationSec / 60);
    }

    return dayData;
  }

  /// 일별 데이터 (최근 30일)
  Future<Map<int, double>> getDailyData() async {
    final all = await getAll();
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final monthSessions = all.where((s) => s.startedAt.isAfter(monthAgo)).toList();

    // 날짜별 집중 시간 (분 단위)
    final Map<int, double> dayData = {};

    for (var session in monthSessions) {
      final day = session.startedAt.day;
      dayData[day] = (dayData[day] ?? 0) + (session.durationSec / 60);
    }

    return dayData;
  }

  /// 총 통계
  Future<Map<String, dynamic>> getTotalStats() async {
    final all = await getAll();

    if (all.isEmpty) {
      return {
        'totalMinutes': 0,
        'completedCount': 0,
        'totalCount': 0,
        'completionRate': 0.0,
      };
    }

    final totalMinutes = all.fold<double>(0, (sum, s) => sum + (s.durationSec / 60));
    final completedCount = all.where((s) => s.completed).length;
    final totalCount = all.length;
    final completionRate = completedCount / totalCount;

    return {
      'totalMinutes': totalMinutes.round(),
      'completedCount': completedCount,
      'totalCount': totalCount,
      'completionRate': completionRate,
    };
  }

  /// 중단 원인 TOP 3
  Future<List<Map<String, dynamic>>> getTopQuitReasons() async {
    final all = await getAll();
    final quitSessions = all.where((s) => !s.completed && s.quitReason != null).toList();

    if (quitSessions.isEmpty) return [];

    // 원인별 카운트
    final Map<String, int> reasonCount = {};
    for (var session in quitSessions) {
      final reason = session.quitReason ?? 'unknown';
      reasonCount[reason] = (reasonCount[reason] ?? 0) + 1;
    }

    // 정렬 후 TOP 3
    final sorted = reasonCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => {
      'reason': e.key,
      'count': e.value,
    }).toList();
  }

  /// Adaptive 알고리즘
  Future<int> calculateOptimalMinutes() async {
    final recent = await getRecentSessions(limit: 10);

    if (recent.isEmpty) return 25;

    final completedCount = recent.where((s) => s.completed).length;
    final completionRate = completedCount / recent.length;

    final avgMinutes = recent
        .map((s) => s.durationSec / 60)
        .reduce((a, b) => a + b) / recent.length;

    if (completionRate >= 0.8) {
      return (avgMinutes + 5).round().clamp(15, 45);
    } else if (completionRate >= 0.5) {
      return avgMinutes.round().clamp(15, 45);
    } else {
      return (avgMinutes - 5).round().clamp(15, 45);
    }
  }
}
