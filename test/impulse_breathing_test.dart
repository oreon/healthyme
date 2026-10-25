// Tests for the impulse box-breathing preset: one minute of
// voiced 4×4 with the motivational reminder, launched directly.

import 'package:flutter_test/flutter_test.dart';

import 'package:healthyme/impulse_breathing.dart';

void main() {
  group('impulsePresetFor', () {
    test('is fixed at 60 seconds of 4/4/4/4 for any source', () {
      for (final source in ['before_eating', 'before_scrolling']) {
        final preset = impulsePresetFor(source);
        expect(preset.source, source);
        expect(preset.totalSeconds, 60);
        expect(preset.phaseSeconds, [4, 4, 4, 4]);
        expect(preset.phaseNames, ['In', 'Hold', 'Out', 'Hold']);
        // One full cycle is 16 s; the four phase lengths fill it.
        expect(preset.phaseSeconds.fold(0, (a, b) => a + b), 16);
      }
    });

    test('carries the life-goals motivational reminder', () {
      final preset = impulsePresetFor('before_eating');
      expect(preset.reminder, impulseReminder);
      expect(preset.reminder, contains('shallow pleasure'));
    });
  });

  group('spokenCueFor', () {
    final preset = impulsePresetFor('before_scrolling');

    test('speaks the phase name as each phase begins', () {
      expect(
          spokenCueFor(preset: preset, phaseIndex: 0, secondInPhase: 0),
          'In');
      expect(
          spokenCueFor(preset: preset, phaseIndex: 1, secondInPhase: 0),
          'Hold');
      expect(
          spokenCueFor(preset: preset, phaseIndex: 2, secondInPhase: 0),
          'Out');
      expect(
          spokenCueFor(preset: preset, phaseIndex: 3, secondInPhase: 0),
          'Hold');
    });

    test('counts two, three, four within each phase', () {
      expect(
          spokenCueFor(preset: preset, phaseIndex: 0, secondInPhase: 1),
          'two');
      expect(
          spokenCueFor(preset: preset, phaseIndex: 0, secondInPhase: 2),
          'three');
      expect(
          spokenCueFor(preset: preset, phaseIndex: 0, secondInPhase: 3),
          'four');
    });

    test('says nothing outside the phases', () {
      expect(
          spokenCueFor(preset: preset, phaseIndex: 4, secondInPhase: 0),
          isNull);
      expect(
          spokenCueFor(preset: preset, phaseIndex: 0, secondInPhase: 4),
          isNull);
    });
  });
}
