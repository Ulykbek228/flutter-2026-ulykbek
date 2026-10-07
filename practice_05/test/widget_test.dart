import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:never_overflows/contact_card.dart';
import 'package:never_overflows/contacts.dart';
import 'package:never_overflows/main.dart';

void main() {
  testWidgets('long name wraps without overflow on a phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[4])),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('list shows a header and builds cards with dividers', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('20 contacts'), findsOneWidget);
    expect(find.byType(ContactCard), findsWidgets);
    expect(find.byType(Divider), findsWidgets);
  });

  testWidgets('badge is absent when unread is 0', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[0])),
      ),
    );
    expect(find.byType(Positioned), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[3])),
      ),
    );
    expect(find.text('3'), findsOneWidget);
  });
}
