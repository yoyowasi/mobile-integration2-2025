// lib/features/timer/data/session_model.dart
class SessionModel {
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec; // 실사용 시간(초)
  final String mode;     // 'auto' | 'custom'
  final bool completed;  // 목표 달성 여부
  final String? quitReason;

  SessionModel({
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.mode,
    required this.completed,
    this.quitReason,
  });

  Map<String, dynamic> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'durationSec': durationSec,
    'mode': mode,
    'completed': completed,
  };

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    startedAt: DateTime.parse(json['startedAt'] as String),
    endedAt: DateTime.parse(json['endedAt'] as String),
    durationSec: json['durationSec'] as int,
    mode: json['mode'] as String,
    completed: json['completed'] as bool,
  );
}
