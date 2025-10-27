import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/timer_notifier.dart';
import '../application/timer_state.dart';
import '../../../core/utils/time_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Adaptive Pomodoro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.phase == TimerPhase.focus
                  ? 'Focus'
                  : state.phase == TimerPhase.rest
                      ? 'Break'
                      : 'Idle',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              formatSeconds(state.secondsLeft),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: () => notifier.startFocus(25),
                  child: const Text('Start Focus (25m)'),
                ),
                OutlinedButton(
                  onPressed: () => notifier.startRest(5),
                  child: const Text('Start Break (5m)'),
                ),
                OutlinedButton(
                  onPressed: () => notifier.pause(),
                  child: const Text('Pause'),
                ),
                OutlinedButton(
                  onPressed: () => notifier.resume(),
                  child: const Text('Resume'),
                ),
                TextButton(
                  onPressed: () => notifier.stop(),
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Planned: ${state.plannedSeconds ~/ 60} min'),
          ],
        ),
      ),
    );
  }
}
