import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthyme/help_me_screen.dart';

void main() {
  testWidgets('Help Me opens the four support choices', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpMeScreen()));

    expect(find.text('Strong emotion'), findsOneWidget);
    expect(find.text('Help me sleep'), findsOneWidget);
    expect(find.text('Help me focus'), findsOneWidget);
    expect(find.text('Pause an impulse'), findsOneWidget);
  });

  testWidgets('Help Me opens a one-minute pause plan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpMeScreen()));
    await tester.tap(find.text('Pause an impulse'));
    await tester.pumpAndSettle();

    expect(find.text('One-minute pause'), findsOneWidget);
    expect(find.text('60 seconds'), findsOneWidget);
  });
}
