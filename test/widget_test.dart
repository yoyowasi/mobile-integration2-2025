import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_integration2_2025/main.dart';

void main() {
  testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PomodoroApp()));

    // Verify that the AppBar title is rendered.
    expect(find.text('Adaptive Pomodoro'), findsOneWidget);

    // Verify that the initial state text 'Idle' is present.
    expect(find.text('Idle'), findsOneWidget);

    // Verify that the 'Start Focus' button is present.
    expect(find.widgetWithText(FilledButton, 'Start Focus (25m)'), findsOneWidget);
  });
}