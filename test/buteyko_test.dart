// Tests for the Buteyko session model: the Control Pause is
// optional, and the guided sequence is exactly
// [reduced 120 s with an 8-second bell cadence, normal 60 s] × 2.

import 'package:flutter_test/flutter_test.dart';

import 'package:healthyme/buteyko.dart';

void main() {
  group('ButeykoProgram', () {
    test('the Control Pause step is optional (always skippable)', () {
      expect(buteykoProgram.controlPauseOptional, isTrue);
    });

    test('sequence is [reduced 120s bell 8s, normal 60s] twice', () {
      final phases = buteykoProgram.phases;
      expect(phases, hasLength(4));

      for (var round = 1; round <= 2; round++) {
        final reduced = phases[(round - 1) * 2];
        final normal = phases[(round - 1) * 2 + 1];

        expect(reduced.kind, 'reduced');
        expect(reduced.round, round);
        expect(reduced.durationSeconds, 120);
        expect(reduced.bellIntervalSeconds, 8);

        expect(normal.kind, 'normal');
        expect(normal.round, round);
        expect(normal.durationSeconds, 60);
        expect(normal.bellIntervalSeconds, isNull);
      }

      expect(buteykoProgram.rounds, 2);
    });

    test('total guided breathing is 360 seconds (CP excluded)', () {
      expect(buteykoProgram.totalGuidedSeconds, 360);
    });

    test('reduced phases ring the soft bell every 8 seconds', () {
      final reduced = buteykoProgram.phases.first;
      final bells = bellOffsetsInPhase(reduced);

      expect(bells.first, 8);
      expect(bells.last, 120);
      for (var i = 1; i < bells.length; i++) {
        expect(bells[i] - bells[i - 1], 8);
      }
    });

    test('normal phases have no bells', () {
      final normal = buteykoProgram.phases[1];
      expect(bellOffsetsInPhase(normal), isEmpty);
    });
  });
}
