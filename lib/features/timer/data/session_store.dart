import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_model.dart';

class SessionStore {
  static const _key = 'sessions';

  /// 세션 저장
  Future<void> append(SessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.add(session);
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  /// 모든 세션 불러오기
  Future<List<SessionModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null) return [];
    final List<dynamic> decoded = jsonDecode(str);
    return decoded.map((e) => SessionModel.fromJson(e)).toList();
  }

  /// 최근 세션 불러오기 (기본 10개)
  Future<List<SessionModel>> getRecentSessions({int limit = 10}) async {
    final all = await getAll();
    return all.reversed.take(limit).toList();
  }

  /// 모든 데이터 삭제
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ===============================================================
  // 🔥 통계용 메서드 (비동기 - 기존 코드 호환용)
  // ===============================================================

  Future<Map<String, double>> getWeeklyData() async {
    final all = await getAll();
    return calculateWeeklyData(all);
  }

  Future<Map<String, double>> getDailyData() async {
    final all = await getAll();
    return calculateDailyData(all);
  }

  Future<Map<String, dynamic>> getTotalStats() async {
    final all = await getAll();
    return calculateTotalStats(all);
  }

  Future<List<Map<String, dynamic>>> getTopQuitReasons() async {
    final all = await getAll();
    return calculateTopQuitReasons(all);
  }

  // ===============================================================
  // 📊 통계 계산 알고리즘 (동기 메서드 - Provider에서 사용)
  // ===============================================================

  /// 1. 주간 데이터 (이번 주 월요일 ~ 오늘)
  Map<String, double> calculateWeeklyData(List<SessionModel> allSessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: now.weekday - 1));

    final weekSessions = allSessions.where((s) =>
    s.startedAt.isAfter(monday) || s.startedAt.isAtSameMomentAs(monday)
    ).toList();

    final Map<String, double> dayData = {
      'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0,
    };

    for (var session in weekSessions) {
      final dayKey = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][session.startedAt.weekday - 1];
      dayData[dayKey] = (dayData[dayKey] ?? 0) + (session.durationSec / 60);
    }
    return dayData;
  }

  /// 2. 일별 데이터 (최근 14일 - 날짜별)
  Map<String, double> calculateDailyData(List<SessionModel> allSessions) {
    final now = DateTime.now();
    final Map<String, double> dayData = {};

    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = "${date.month}/${date.day}";
      dayData[key] = 0.0;
    }

    final startDate = now.subtract(const Duration(days: 15));
    final targetSessions = allSessions.where((s) => s.startedAt.isAfter(startDate)).toList();

    for (var session in targetSessions) {
      final d = session.startedAt;
      final key = "${d.month}/${d.day}";
      if (dayData.containsKey(key)) {
        dayData[key] = (dayData[key] ?? 0) + (session.durationSec / 60);
      }
    }
    return dayData;
  }

  /// 🔥 3. 시간대별 데이터 (오늘 0시 ~ 23시) - [이 부분이 누락되었었습니다]
  Map<int, double> calculateHourlyData(List<SessionModel> allSessions) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // 오늘 데이터만 필터링
    final todaySessions = allSessions.where((s) =>
    (s.startedAt.isAfter(todayStart) || s.startedAt.isAtSameMomentAs(todayStart)) &&
        s.startedAt.isBefore(todayEnd)
    ).toList();

    // 0~23시 초기화
    final Map<int, double> hourlyData = {};
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0.0;
    }

    // 시간대별 합산
    for (var session in todaySessions) {
      final hour = session.startedAt.hour;
      hourlyData[hour] = (hourlyData[hour] ?? 0) + (session.durationSec / 60);
    }

    return hourlyData;
  }

  /// 4. 전체 통계
  Map<String, dynamic> calculateTotalStats(List<SessionModel> allSessions) {
    if (allSessions.isEmpty) {
      return {
        'totalMinutes': 0,
        'completedCount': 0,
        'totalCount': 0,
        'completionRate': 0.0,
      };
    }

    final totalMinutes = allSessions.fold<double>(0, (sum, s) => sum + (s.durationSec / 60));
    final completedCount = allSessions.where((s) => s.completed).length;
    final totalCount = allSessions.length;
    final completionRate = completedCount / totalCount;

    return {
      'totalMinutes': totalMinutes.round(),
      'completedCount': completedCount,
      'totalCount': totalCount,
      'completionRate': completionRate,
    };
  }

  /// 5. 중단 원인 TOP 3
  List<Map<String, dynamic>> calculateTopQuitReasons(List<SessionModel> allSessions) {
    final quitSessions = allSessions.where((s) => !s.completed && s.quitReason != null).toList();

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
    // 1. 저장된 모든 세션 데이터를 불러옵니다.
    final allSessions = await getAll();

    // 데이터가 하나도 없으면 추천할 수 없으므로 null을 반환합니다.
    if (allSessions.isEmpty) return null;

    // 2. 현재 상황(Context) 파악: 사용자가 집중하려는 '현재 시간대'
    final now = DateTime.now();
    final currentHour = now.hour;

    // 3. [맥락 필터링 (Contextual Filtering)]
    // 전체 기록 중, 현재 시간대와 비슷한(앞뒤 3시간) 기록들만 추출합니다.
    // 이유: 아침의 집중력과 밤의 집중력 패턴은 다를 수 있기 때문에,
    //      현재 시간대와 유사한 과거 데이터를 우선적으로 분석합니다.
    final contextSessions = allSessions.where((s) {
      final h = s.startedAt.hour;
      return (h - currentHour).abs() <= 3; // ±3시간 이내 데이터 (예: 14시라면 11~17시 기록)
    }).toList();

    // * 데이터 부족 처리 (Cold Start 방지)
    // 해당 시간대 기록이 너무 적다면(5개 미만), 통계적 의미가 약하므로
    // 시간대 상관없이 '전체 기록 중 가장 최근 20개'를 대신 사용합니다.
    final targetSessions = contextSessions.length < 5
        ? allSessions.reversed.take(20).toList()
        : contextSessions;

    // 필터링 후에도 데이터가 없으면 null 반환
    if (targetSessions.isEmpty) return null;

    double weightedSum = 0; // 가중 합계 (시간 * 가중치)
    double totalWeight = 0; // 전체 가중치 합

    // 4. [가중 이동 평균 (Weighted Moving Average)]
    // 추출된 기록들을 순회하며 가중치를 적용해 평균 집중 시간을 계산합니다.
    for (int i = 0; i < targetSessions.length; i++) {
      final session = targetSessions[i];
      final durationMin = session.durationSec / 60;

      // A. [시간 감쇠 (Time Decay)]
      // 과거의 기록보다 최신 기록이 현재 내 상태를 더 잘 반영합니다.
      // 인덱스(i)가 클수록(최신일수록) 더 높은 가중치를 줍니다.
      double recencyWeight = (i + 1) / targetSessions.length;

      // B. [성과 가중치 (Outcome Weight)]
      // 성공한 세션(완주)은 1.1배 가중치를 주어 "이 정도는 충분히 할 수 있다"고 판단하여 시간을 늘리는 방향으로,
      // 실패한 세션(중단)은 0.8배로 낮춰 "이 시간은 힘들다"고 판단하여 시간을 줄이는 방향으로 유도합니다.
      double outcomeWeight = session.completed ? 1.1 : 0.8;

      // 최종 가중치 = 최신성 * 성과
      final finalWeight = recencyWeight * outcomeWeight;

      weightedSum += durationMin * finalWeight;
      totalWeight += finalWeight;
    }

    // 예측된 최적 시간 = 가중 합계 / 총 가중치
    double predictedMinutes = weightedSum / totalWeight;

    // 5. [스마트 보정 (Heuristic Adjustment)]
    // 단순 평균의 맹점을 보완하기 위한 안전장치입니다.
    // 최근 3번의 시도 중 2번 이상 실패(중단)했다면, 사용자가 지쳐있거나 슬럼프일 확률이 높습니다.
    // 이 경우 계산된 추천 시간보다 강제로 5분을 더 줄여서 부담을 덜어줍니다.
    final recentFailures = targetSessions.reversed.take(3).where((s) => !s.completed).length;
    if (recentFailures >= 2) {
      predictedMinutes -= 5;
    }

    // 6. 최종 포맷팅
    // 소수점은 반올림하고, 뽀모도로의 일반적인 범위인 최소 10분 ~ 최대 60분 사이로 제한(Clamp)합니다.
    int result = predictedMinutes.round();
    return result.clamp(10, 60);
  }
}