// Tests for the Wave 2 daily plan: bundled spec template, section
// derivation, phone-off pinning, and reset-to-defaults storage behavior.

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthyme/database_helper.dart';
import 'package:healthyme/plan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bundled default plan template', () {
    test('contains the spec defaults with exact labels and times', () async {
      final tasks = parsePlanTasks(
          await rootBundle.loadString('assets/tasks.json'));

      final byName = <String, Map<String, dynamic>>{
        for (final task in tasks) task['taskname'] as String: task,
      };

      const expectedTimes = {
        'Water': '06:00',
        'Meditation': '06:20',
        'Strength': '07:00',
        'Yoga': '07:30',
        'Mindful breakfast': '08:00',
        'Yoga Nidra': '12:00',
        'Mindful lunch': '13:30',
        'Box breathing (5 minutes)': '14:00',
        'Fluid reminder': '15:00',
        'Evening meditation': '19:00',
        'Wind down': '19:30',
      };
      expectedTimes.forEach((name, time) {
        expect(byName[name], isNotNull, reason: 'missing task "$name"');
        expect(byName[name]!['time'], time, reason: 'wrong time for "$name"');
      });

      // Meal tasks use the exact "Mindful ..." labels.
      expect(byName.keys, containsAll(['Mindful breakfast', 'Mindful lunch']));
    });

    test('journal is immediately before Turn phone off, which is last',
        () async {
      final tasks = parsePlanTasks(
          await rootBundle.loadString('assets/tasks.json'));

      expect(tasks.last['taskname'], 'Turn phone off');
      expect(tasks.last['time'], '20:00');
      final journalIndex =
          tasks.indexWhere((t) => t['taskname'] == 'Journal');
      expect(journalIndex, tasks.length - 2);
      expect(tasks[journalIndex]['time'], '19:45');
    });

    test('every template task has a unique id and a parseable time',
        () async {
      final tasks = parsePlanTasks(
          await rootBundle.loadString('assets/tasks.json'));

      final ids = tasks.map((t) => t['id']).toSet();
      expect(ids.length, tasks.length);
      for (final task in tasks) {
        expect(timeToMinutes(task['time'] as String?), isNotNull,
            reason: 'unparseable time on "${task['taskname']}"');
      }
    });
  });

  group('sectionForTime', () {
    test('derives sections at the noon and 18:00 boundaries', () {
      expect(sectionForTime('00:00'), DaySection.morning);
      expect(sectionForTime('11:59'), DaySection.morning);
      expect(sectionForTime('12:00'), DaySection.afternoon);
      expect(sectionForTime('17:59'), DaySection.afternoon);
      expect(sectionForTime('18:00'), DaySection.evening);
      expect(sectionForTime('23:59'), DaySection.evening);
      expect(sectionForTime(null), DaySection.morning);
    });
  });

  group('pinPhoneOffLast', () {
    test('moves Turn phone off to the end, preserving other order', () {
      final tasks = parsePlanTasks(
          '[{"id":1,"taskname":"Turn phone off"},{"id":2,"taskname":"Journal"},{"id":3,"taskname":"Water"}]');
      final pinned = pinPhoneOffLast(tasks);
      expect(pinned.map((t) => t['taskname']).toList(),
          ['Journal', 'Water', 'Turn phone off']);
    });
  });

  group('plan storage', () {
    test(
        'first run seeds the template; reset restores it and preserves '
        'points and profile', () async {
      SharedPreferences.setMockInitialValues({});
      final db = DatabaseHelper();
      final prefs = await SharedPreferences.getInstance();
      final templateJson = await rootBundle.loadString('assets/tasks.json');
      final template = parsePlanTasks(templateJson);

      // First run: nothing stored, seeding falls back to the template.
      expect(await db.getUserPlan(), isNull);
      final seeded = await loadPlanOrSeed(db, templateJson);
      expect(seeded, template);
      expect(await db.getUserPlan(), template);

      // Unrelated data that must survive a reset.
      await prefs.setString('name', 'Jag');
      await db.awardPoints(10);
      await db.awardSessionPoints('session-1', 40);

      // User deletes every task, then resets.
      await db.saveUserPlan(<Map<String, dynamic>>[]);
      final restored = await resetPlanToDefaults(db, templateJson);
      expect(restored, template);
      expect(await db.getUserPlan(), template);

      // History-adjacent data survived: profile value, score total and
      // the already-credited session (re-awarding it adds nothing).
      expect(prefs.getString('name'), 'Jag');
      expect(await db.getTodaysScore(), 50);
      expect(await db.awardSessionPoints('session-1', 40), 0);
    });
  });
}
