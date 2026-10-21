import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screens_lead/main.dart';

void main() {
  testWidgets('list -> detail -> edit -> save changes the name', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('aida@kbtu.kz'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Aida New');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Aida New'), findsOneWidget);
  });

  testWidgets('backing out of a clean form changes nothing', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Dias Nurlanov'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Dias Nurlanov'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a dirty form asks before leaving', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Madina Serik'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'X');
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text('madina@kbtu.kz'), findsOneWidget);
    expect(find.text('Madina Serik'), findsOneWidget);
  });
}
