// Tests for the session-draft model (serialize/restore round-trip)
// and for practiced-time accounting (rest and skipped time are
// never credited).

import 'package:flutter_test/flutter_test.dart';

import 'package:healthyme/session_draft.dart';

void main() {
  group('SessionDraft', () {
    test('serializes and restores a workout draft round-trip', () {
      const draft = SessionDraft(
        kind: 'workout',
        identity: 'Yoga',
        sessionKey: 'workout:Yoga:12345',
        exerciseIndex: 3,
        set: 2,
        activeSeconds: 640,
        skipped: ['1:1', '2:1'],
        date: '2026-10-25',
        savedAtMillis: 1792891200000,
      );

      final restored = SessionDraft.fromJson(draft.toJson());

      expect(restored.kind, 'workout');
      expect(restored.identity, 'Yoga');
      expect(restored.sessionKey, 'workout:Yoga:12345');
      expect(restored.exerciseIndex, 3);
      expect(restored.set, 2);
      expect(restored.activeSeconds, 640);
      expect(restored.selectedDurationMinutes, isNull);
      expect(restored.skipped, ['1:1', '2:1']);
      expect(restored.date, '2026-10-25');
      expect(restored.savedAtMillis, 1792891200000);
    });

    test('serializes and restores a meditation draft round-trip', () {
      const draft = SessionDraft(
        kind: 'meditation',
        identity: 'Body Scan',
        sessionKey: 'meditation:Body Scan:999',
        activeSeconds: 300,
        selectedDurationMinutes: 15,
        date: '2026-10-25',
        savedAtMillis: 1792891200000,
      );

      final restored = SessionDraft.fromJson(draft.toJson());

      expect(restored.kind, 'meditation');
      expect(restored.identity, 'Body Scan');
      expect(restored.sessionKey, 'meditation:Body Scan:999');
      expect(restored.activeSeconds, 300);
      expect(restored.selectedDurationMinutes, 15);
      expect(restored.exerciseIndex, 0);
      expect(restored.set, 1);
      expect(restored.skipped, isEmpty);
    });
  });

  group('PracticeTimeTracker', () {
    test('only unpaused work-phase ticks count as practiced time', () {
      final tracker = PracticeTimeTracker();

      for (var i = 0; i < 30; i++) {
        tracker.tick(isWorkPhase: true, isPaused: false);
      }
      expect(tracker.activeSeconds, 30);

      // Rest-phase seconds never advance the practiced total.
      for (var i = 0; i < 15; i++) {
        tracker.tick(isWorkPhase: false, isPaused: false);
      }
      expect(tracker.activeSeconds, 30);

      // Paused wall-clock time never advances it either.
      for (var i = 0; i < 60; i++) {
        tracker.tick(isWorkPhase: true, isPaused: true);
      }
      expect(tracker.activeSeconds, 30);
    });

    test('a skipped exercise is not practiced and earns no time', () {
      final tracker = PracticeTimeTracker();

      // Practice 10 s of exercise 0, then skip it: its remaining
      // seconds are never ticked, so they are never credited.
      for (var i = 0; i < 10; i++) {
        tracker.tick(isWorkPhase: true, isPaused: false);
      }
      tracker.skipExercise(0, 1);

      expect(tracker.isPracticed(0, 1), isFalse);
      expect(tracker.isPracticed(1, 1), isTrue);
      expect(tracker.hasSkips, isTrue);
      expect(tracker.skippedKeys, {'0:1'});

      // The next exercise practices normally.
      for (var i = 0; i < 45; i++) {
        tracker.tick(isWorkPhase: true, isPaused: false);
      }
      expect(tracker.activeSeconds, 55);
      expect(tracker.isPracticed(1, 1), isTrue);
    });

    test('skipped keys survive a restore (draft resume)', () {
      final tracker = PracticeTimeTracker();
      tracker.skipExercise(2, 1);
      tracker.activeSeconds = 120;

      final restored = PracticeTimeTracker();
      restored.restoreSkipped(tracker.skippedKeys);
      restored.activeSeconds = tracker.activeSeconds;

      expect(restored.isPracticed(2, 1), isFalse);
      expect(restored.hasSkips, isTrue);
      expect(restored.activeSeconds, 120);
    });
  });
}
