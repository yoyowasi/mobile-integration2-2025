// lib/features/timer/data/session_model.dart

/// 포모도로(집중) 세션 모델
/// 한 번의 집중 타이머 실행 정보를 저장
class PomodoroSession {
  final String id; // 세션 고유 ID
  final DateTime startedAt; // 시작 시각
  final DateTime? endedAt; // 종료 시각
  final int plannedFocusMinutes; // 계획된 집중 시간
  final int actualFocusMinutes; // 실제 집중한 시간
  final bool completed; // 완료 여부
  final DateTime? interruptedAt; // 중단 시각 (있을 경우)
  final String source; // "auto" 또는 "custom"

  PomodoroSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.plannedFocusMinutes,
    required this.actualFocusMinutes,
    required this.completed,
    this.interruptedAt,
    required this.source,
  });

  /// JSON 변환용 (저장 시)
  Map<String, dynamic> toJson() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'planned': plannedFocusMinutes,
    'actual': actualFocusMinutes,
    'completed': completed,
    'interruptedAt': interruptedAt?.toIso8601String(),
    'source': source,
  };

  /// JSON → 객체 복원용 (불러오기 시)
  static PomodoroSession fromJson(Map<String, dynamic> j) => PomodoroSession(
    id: j['id'] as String,
    startedAt: DateTime.parse(j['startedAt'] as String),
    endedAt: j['endedAt'] == null ? null : DateTime.parse(j['endedAt']),
    plannedFocusMinutes: (j['planned'] as num).toInt(),
    actualFocusMinutes: (j['actual'] as num).toInt(),
    completed: j['completed'] as bool,
    interruptedAt: j['interruptedAt'] == null
        ? null
        : DateTime.parse(j['interruptedAt']),
    source: j['source'] as String,
  );
}
