import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_screen/main.dart';

void main() {
  testWidgets('tap card counts, Cancel keeps, Reset zeroes', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.text('Tap this card'));
    }
    await tester.pump();
    expect(find.text('10'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('10'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Reset'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('10'), findsNothing);
  });

  testWidgets('minus is disabled at zero, Save cannot run twice', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final minus = find.widgetWithText(OutlinedButton, '−');
    expect(tester.widget<OutlinedButton>(minus).onPressed, isNull);

    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pump();
    expect(tester.widget<OutlinedButton>(minus).onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('stopwatch counts and shows mm:ss', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('00:00'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:03'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:03'), findsOneWidget);
  });
}
