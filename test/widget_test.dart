// Widget test for the completion dialog: it renders "Well done!",
// the session's points, the encouragement line, the formatted
// duration and the five feeling faces.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthyme/activity_complete_dialog.dart';
import 'package:healthyme/completion.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openDialog(
    WidgetTester tester, {
    required String workoutName,
    required int elapsedTime,
    int pointsEarned = 0,
    String encouragement = physicalEncouragement,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                WorkoutCompleteDialog(
                  context: context,
                  workoutName: workoutName,
                  elapsedTime: elapsedTime,
                  pointsEarned: pointsEarned,
                  encouragement: encouragement,
                ).show();
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Completion dialog shows Well done, points and faces',
      (WidgetTester tester) async {
    await openDialog(
      tester,
      workoutName: 'Sun Salutation',
      elapsedTime: 125,
      pointsEarned: 4,
    );

    expect(find.text('Well done!'), findsOneWidget);
    expect(find.textContaining('Sun Salutation'), findsOneWidget);
    expect(find.textContaining('You earned 4 points'), findsOneWidget);
    expect(find.text(physicalEncouragement), findsOneWidget);
    expect(find.textContaining('Total Duration: 2:05'), findsOneWidget);
    for (final face in feelingFaces) {
      expect(find.text(face), findsOneWidget);
    }
    expect(find.byIcon(Icons.share), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    // A feeling face can be selected.
    await tester.tap(find.text('🙂'));
    await tester.pumpAndSettle();
    expect(find.text('🙂'), findsOneWidget);
  });

  testWidgets('Completion dialog pads single-digit seconds',
      (WidgetTester tester) async {
    await openDialog(
      tester,
      workoutName: 'Breathwork',
      elapsedTime: 61,
    );

    expect(find.textContaining('Total Duration: 1:01'), findsOneWidget);
  });
}
