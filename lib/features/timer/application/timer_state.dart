enum TimerPhase { idle, focus, rest, paused }

class TimerState {
  final TimerPhase phase;
  final int secondsLeft;
  final int plannedSeconds;

  const TimerState({
    this.phase = TimerPhase.idle,
    this.secondsLeft = 0,
    this.plannedSeconds = 0,
  });

  bool get running => phase == TimerPhase.focus || phase == TimerPhase.rest;

  TimerState copyWith({
    TimerPhase? phase,
    int? secondsLeft,
    int? plannedSeconds,
  }) {
    return TimerState(
      phase: phase ?? this.phase,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
    );
  }
}
