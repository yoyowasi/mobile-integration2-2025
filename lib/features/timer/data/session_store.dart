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

  // 🔥 === 통계용 메서드 ===

  /// 주간 데이터 (최근 7일)
  Future<Map<String, double>> getWeeklyData() async {
    final all = await getAll();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekSessions = all.where((s) => s.startedAt.isAfter(weekAgo)).toList();

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
      final weekday = session.startedAt.weekday;
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

    final Map<String, int> reasonCount = {};
    for (var session in quitSessions) {
      final reason = session.quitReason ?? 'unknown';
      reasonCount[reason] = (reasonCount[reason] ?? 0) + 1;
    }

    final sorted = reasonCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => {
      'reason': e.key,
      'count': e.value,
    }).toList();
  }

  Future<int?> calculateOptimalMinutes() async {
    final allSessions = await getAll();

    // 1. 데이터가 없으면 계산하지 않음 (기본값 25 반환 로직 제거)
    if (allSessions.isEmpty) return null;

    // 2. 현재 상황(Context) 파악: 시간대 (오전/오후/밤)
    final now = DateTime.now();
    final currentHour = now.hour;

    // 3. 맥락 필터링 (Contextual Filtering)
    // 현재 시간대와 비슷한(앞뒤 3시간) 기록들을 추출하여 '이 시간대의 집중력'을 분석
    final contextSessions = allSessions.where((s) {
      final h = s.startedAt.hour;
      return (h - currentHour).abs() <= 3; // ±3시간 이내 데이터
    }).toList();

    // * 데이터가 너무 적으면(5개 미만) 전체 최근 기록 20개를 대신 사용 (Cold Start 방지)
    final targetSessions = contextSessions.length < 5
        ? allSessions.reversed.take(20).toList()
        : contextSessions;

    if (targetSessions.isEmpty) return null;

    double weightedSum = 0;
    double totalWeight = 0;

    // 4. 가중 이동 평균 (Weighted Moving Average) 계산
    for (int i = 0; i < targetSessions.length; i++) {
      final session = targetSessions[i];
      final durationMin = session.durationSec / 60;

      // A. 최신 데이터 가중치 (Time Decay): 최신일수록 가중치 높음
      double recencyWeight = (i + 1) / targetSessions.length;

      // B. 성과 가중치 (Performance Weight): 성공시 1.1배, 실패시 0.8배 반영
      double outcomeWeight = session.completed ? 1.1 : 0.8;

      final finalWeight = recencyWeight * outcomeWeight;

      weightedSum += durationMin * finalWeight;
      totalWeight += finalWeight;
    }

    // 예측된 최적 시간
    double predictedMinutes = weightedSum / totalWeight;

    // 5. 스마트 보정 (Heuristic Adjustment)
    // 최근 3번 중 2번 이상 실패했다면, 계산된 값보다 강제로 5분 더 줄여서 부담 완화
    final recentFailures = targetSessions.reversed.take(3).where((s) => !s.completed).length;
    if (recentFailures >= 2) {
      predictedMinutes -= 5;
    }

    // 6. 최종 포맷팅 (분 단위 반올림 & 범위 제한)
    int result = predictedMinutes.round();
    return result.clamp(10, 60); // 최소 10분, 최대 60분
  }
}