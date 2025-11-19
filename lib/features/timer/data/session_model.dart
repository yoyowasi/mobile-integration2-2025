class SessionModel {
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;
  final String mode;
  final bool completed;
  final String? quitReason;  // 🔥 Quick Log용

  SessionModel({
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.mode,
    required this.completed,
    this.quitReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'startedAt': startedAt.millisecondsSinceEpoch,
      'endedAt': endedAt.millisecondsSinceEpoch,
      'durationSec': durationSec,
      'mode': mode,
      'completed': completed,
      'quitReason': quitReason,
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      startedAt: DateTime.fromMillisecondsSinceEpoch(json['startedAt']),
      endedAt: DateTime.fromMillisecondsSinceEpoch(json['endedAt']),
      durationSec: json['durationSec'],
      mode: json['mode'],
      completed: json['completed'],
      quitReason: json['quitReason'],
    );
  }
}
