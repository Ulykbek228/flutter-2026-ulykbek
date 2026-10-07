import 'package:flutter_test/flutter_test.dart';
import 'package:profile_screen/data.dart';
import 'package:profile_screen/info_row.dart';
import 'package:profile_screen/main.dart';

void main() {
  testWidgets('profile shows name and one InfoRow per fact', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('My profile'), findsOneWidget);
    expect(find.text(myName), findsOneWidget);
    expect(find.byType(InfoRow), findsNWidgets(facts.length));
  });
}
