// Unit tests for the points engine and the morning strength alternation.

import 'package:flutter_test/flutter_test.dart';

import 'package:healthyme/points.dart';
import 'package:healthyme/strength_alternation.dart';

void main() {
  group('sessionPoints', () {
    test('no points below one completed active minute', () {
      expect(sessionPoints(0), 0);
      expect(sessionPoints(59), 0);
    });

    test('two points per completed active minute', () {
      expect(sessionPoints(60), 2);
      expect(sessionPoints(119), 2);
      expect(sessionPoints(20 * 60), 40);
    });

    test('caps at 120 points (one hour) per session', () {
      expect(sessionPoints(60 * 60), 120);
      expect(sessionPoints(90 * 60), 120);
    });
  });

  group('strength alternation (1-based day of year)', () {
    test('Jan 1 is day 1 and an upper-body day', () {
      final jan1 = DateTime(2026, 1, 1);
      expect(dayOfYear(jan1), 1);
      expect(isUpperBodyDay(jan1), isTrue);
    });

    test('Jan 2 is day 2 and a lower-body day', () {
      final jan2 = DateTime(2026, 1, 2);
      expect(dayOfYear(jan2), 2);
      expect(isUpperBodyDay(jan2), isFalse);
    });

    test('leap years are handled: Dec 31 2028 is day 366', () {
      expect(dayOfYear(DateTime(2028, 12, 31)), 366);
    });
  });
}
