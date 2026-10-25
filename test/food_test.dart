// Tests for Wave 5 food records: eating-window derivation, the food
// snapshot record, caffeine entries, and the "Benefits" label rule.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthyme/database_helper.dart';
import 'package:healthyme/food.dart';

void main() {
  group('deriveEatingWindow', () {
    test('empty day has no window', () {
      expect(deriveEatingWindow(const []), isNull);
    });

    test('single entry is a zero-length window at that time', () {
      final at = DateTime(2026, 10, 25, 8, 5);
      final window = deriveEatingWindow([at])!;
      expect(window.first, at);
      expect(window.last, at);
      expect(window.duration, Duration.zero);
      expect(window.describe(), 'Eating window today: 08:05 (0 min)');
    });

    test('multiple entries use earliest and latest, order-free', () {
      final window = deriveEatingWindow([
        DateTime(2026, 10, 25, 19, 42),
        DateTime(2026, 10, 25, 8, 5),
        DateTime(2026, 10, 25, 13, 30),
      ])!;
      expect(window.first, DateTime(2026, 10, 25, 8, 5));
      expect(window.last, DateTime(2026, 10, 25, 19, 42));
      expect(window.duration, const Duration(hours: 11, minutes: 37));
      expect(window.describe(),
          'Eating window today: 08:05 – 19:42 (11 h 37 min)');
    });

    test('duration formatting', () {
      expect(EatingWindow.formatDuration(const Duration(minutes: 45)),
          '45 min');
      expect(EatingWindow.formatDuration(Duration.zero), '0 min');
      expect(
          EatingWindow.formatDuration(const Duration(hours: 2, minutes: 3)),
          '2 h 3 min');
    });
  });

  group('meal log scanning', () {
    test('isMealActivity matches meals and snacks only', () {
      expect(isMealActivity('Breakfast'), isTrue);
      expect(isMealActivity('snack'), isTrue);
      expect(isMealActivity('Coffee'), isFalse);
      expect(isMealActivity('yoga'), isFalse);
      expect(isMealActivity(null), isFalse);
    });

    test('mealTimesFromLogs uses real timestamps of meal rows only', () {
      final times = mealTimesFromLogs([
        {'activity': 'Breakfast', 'time': '2026-10-25T08:05:00.000'},
        {'activity': 'Coffee', 'time': '2026-10-25T09:00:00.000'},
        {'activity': 'Snack', 'time': '2026-10-25T16:20:00.000'},
        {'activity': 'Dinner', 'time': 'not-a-time'},
      ]);
      expect(times, [
        DateTime(2026, 10, 25, 8, 5),
        DateTime(2026, 10, 25, 16, 20),
      ]);
    });

    test('default meal by time of day', () {
      expect(defaultMealForTime(DateTime(2026, 1, 1, 7, 30)), 'Breakfast');
      expect(defaultMealForTime(DateTime(2026, 1, 1, 12, 15)), 'Lunch');
      expect(defaultMealForTime(DateTime(2026, 1, 1, 16, 0)), 'Snack');
      expect(defaultMealForTime(DateTime(2026, 1, 1, 19, 45)), 'Dinner');
    });
  });

  group('FoodSnapshot', () {
    test('json round-trip preserves every field', () {
      final snapshot = FoodSnapshot(
        id: '1761400000000',
        photoPath: '/docs/food_photos/food_1761400000000.jpg',
        meal: 'Lunch',
        capturedAt: DateTime(2026, 10, 25, 13, 30, 15),
        logId: 42,
      );
      final restored = FoodSnapshot.fromJson(snapshot.toJson());
      expect(restored.id, snapshot.id);
      expect(restored.photoPath, snapshot.photoPath);
      expect(restored.meal, snapshot.meal);
      expect(restored.capturedAt, snapshot.capturedAt);
      expect(restored.logId, 42);
      expect(restored.date, '2026-10-25');
    });

    test('json round-trip without a log id', () {
      final snapshot = FoodSnapshot(
        id: '1',
        photoPath: '/x.jpg',
        meal: 'Snack',
        capturedAt: DateTime(2026, 10, 25, 16, 0),
      );
      final restored = FoodSnapshot.fromJson(snapshot.toJson());
      expect(restored.logId, isNull);
      expect(restored.meal, 'Snack');
    });
  });

  group('CaffeineEntry', () {
    test('labels reflect type and cup count', () {
      final coffee = CaffeineEntry(
        type: CaffeineEntry.coffee,
        cups: 2,
        timestamp: DateTime(2026, 10, 25, 9, 0),
      );
      expect(coffee.activityLabel, 'Coffee');
      expect(coffee.displayLabel, 'Coffee · 2 cups');

      final tea = CaffeineEntry(
        type: CaffeineEntry.tea,
        cups: 1,
        timestamp: DateTime(2026, 10, 25, 15, 0),
      );
      expect(tea.activityLabel, 'Tea');
      expect(tea.displayLabel, 'Tea · 1 cup');
    });

    test('json round-trip preserves type, cups and timestamp', () {
      final entry = CaffeineEntry(
        type: CaffeineEntry.tea,
        cups: 3,
        timestamp: DateTime(2026, 10, 25, 15, 30),
      );
      final restored = CaffeineEntry.fromJson(entry.toJson());
      expect(restored.type, CaffeineEntry.tea);
      expect(restored.cups, 3);
      expect(restored.timestamp, entry.timestamp);
    });
  });

  group('DatabaseHelper food records', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('snapshot records persist and delete with their log row',
        () async {
      final db = DatabaseHelper();
      final at = DateTime(2026, 10, 25, 13, 30);
      final snapshot = await db.addFoodSnapshot(
        photoPath: '/docs/food_photos/food_x.jpg',
        meal: 'Lunch',
        capturedAt: at,
      );
      expect(snapshot.logId, isNotNull);

      final today = await db.getFoodSnapshots(date: '2026-10-25');
      expect(today, hasLength(1));
      expect(today.single.meal, 'Lunch');
      expect(today.single.capturedAt, at);

      // The companion log row shows the meal in the day's logs.
      final logs = await db.getLogsByDate(db.getTodaysDate());
      expect(
        logs.any((row) =>
            row['activity'] == 'Lunch' && row['comments'] == 'Food snapshot'),
        isTrue,
      );

      final removed = await db.deleteFoodSnapshot(snapshot.id);
      expect(removed?.photoPath, '/docs/food_photos/food_x.jpg');
      expect(await db.getFoodSnapshots(), isEmpty);
      final logsAfter = await db.getLogsByDate(db.getTodaysDate());
      expect(
        logsAfter.any((row) => row['comments'] == 'Food snapshot'),
        isFalse,
      );
    });

    test('caffeine is logged with its cup count', () async {
      final db = DatabaseHelper();
      await db.logCaffeine(CaffeineEntry(
        type: CaffeineEntry.coffee,
        cups: 2,
        timestamp: DateTime.now(),
      ));
      final logs = await db.getLogsByDate(db.getTodaysDate());
      expect(
        logs.any((row) =>
            row['activity'] == 'Coffee' && row['comments'] == 'Coffee · 2 cups'),
        isTrue,
      );
    });
  });

  group('"Benefits" label', () {
    test('no user-facing "Potential benefits" string remains in lib/', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);
      final offenders = <String>[];
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = entity.readAsStringSync().toLowerCase();
          if (content.contains('potential benefits')) {
            offenders.add(entity.path);
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'The motivational label is "Benefits", not '
              '"Potential benefits" (found in: $offenders)');
    });
  });
}
