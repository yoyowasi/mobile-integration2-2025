import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_state.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(ref),
);

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref ref;
  Timer? _ticker;

  TimerNotifier(this.ref) : super(const TimerState());

  void startFocus(int minutes) => _start(TimerPhase.focus, minutes * 60);
  void startRest(int minutes)  => _start(TimerPhase.rest, minutes * 60);

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(phase: TimerPhase.paused);
  }

  void resume() {
    if (state.phase != TimerPhase.paused) return;
    _tickCurrentPhase();
  }

  void stop() {
    _ticker?.cancel();
    state = const TimerState();
  }

  void _start(TimerPhase phase, int total) {
    _ticker?.cancel();
    state = TimerState(phase: phase, secondsLeft: total, plannedSeconds: total);
    _tickCurrentPhase();
  }

  void _tickCurrentPhase() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = state.secondsLeft - 1;
      if (next <= 0) {
        t.cancel();
        // TODO: save session + notify + auto switch to next phase
        state = const TimerState();
      } else {
        state = state.copyWith(secondsLeft: next);
      }
    });
  }
}
