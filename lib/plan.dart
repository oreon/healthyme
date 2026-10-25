import 'dart:convert';

import 'database_helper.dart';

/// The task that must always stay at the end of the daily plan.
const String phoneOffTaskName = 'Turn phone off';

/// Sections of the day shown on the Today screen.
enum DaySection { morning, afternoon, evening }

extension DaySectionLabel on DaySection {
  String get label {
    switch (this) {
      case DaySection.morning:
        return 'Morning';
      case DaySection.afternoon:
        return 'Afternoon';
      case DaySection.evening:
        return 'Evening';
    }
  }
}

/// The activity library offered when adding a task to the routine.
/// Entries without a screenName open the generic task screen.
const List<Map<String, dynamic>> activityLibrary = [
  {
    'taskname': 'Meditation',
    'tasktype': 'meditation',
    'screenName': 'MeditationScreen',
  },
  {
    'taskname': 'Strength',
    'tasktype': 'exercise',
    'screenName': 'ExerciseScreen',
  },
  {
    'taskname': 'Yoga',
    'tasktype': 'exercise',
    'screenName': 'YogaScreen',
  },
  {
    'taskname': 'Pranayama',
    'tasktype': 'exercise',
    'screenName': 'PranayamaScreen',
  },
  {
    'taskname': 'Box breathing',
    'tasktype': 'breathing',
    'screenName': 'BoxBreathingScreen',
  },
  {
    'taskname': 'Buteyko',
    'tasktype': 'breathing',
    'screenName': 'ButeykoScreen',
  },
  {
    'taskname': 'Journal',
    'tasktype': 'general',
    'screenName': 'JournalScreen',
  },
  {
    'taskname': 'Mindful meal',
    'tasktype': 'diet',
    'screenName': 'DietTab',
  },
  {
    'taskname': 'Custom task',
    'tasktype': 'general',
  },
];

/// Parses a plan task list from JSON (e.g. the bundled template asset).
List<Map<String, dynamic>> parsePlanTasks(String jsonString) {
  final value = json.decode(jsonString);
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((row) => Map<String, dynamic>.from(row))
      .toList();
}

/// Minutes since midnight for an "HH:mm" time, or null when unparseable.
int? timeToMinutes(String? time) {
  if (time == null) return null;
  final parts = time.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}

/// Formats an hour/minute pair as "HH:mm".
String formatHhmm(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

/// Section of the day a scheduled "HH:mm" time belongs to:
/// before 12:00 Morning, 12:00–17:59 Afternoon, 18:00+ Evening.
/// Untimed tasks default to Morning.
DaySection sectionForTime(String? time) {
  final minutes = timeToMinutes(time);
  if (minutes == null || minutes < 12 * 60) return DaySection.morning;
  if (minutes < 18 * 60) return DaySection.afternoon;
  return DaySection.evening;
}

/// A task is overdue when it is not completed and its scheduled time
/// today has already passed.
bool isTaskOverdue(Map<String, dynamic> task, bool completed, DateTime now) {
  if (completed) return false;
  final minutes = timeToMinutes(task['time'] as String?);
  if (minutes == null) return false;
  return minutes < now.hour * 60 + now.minute;
}

/// Returns a copy of [tasks] with "Turn phone off" moved to the end,
/// keeping every other task's relative order.
List<Map<String, dynamic>> pinPhoneOffLast(List<Map<String, dynamic>> tasks) {
  final rest = <Map<String, dynamic>>[];
  final phoneOff = <Map<String, dynamic>>[];
  for (final task in tasks) {
    (task['taskname'] == phoneOffTaskName ? phoneOff : rest).add(task);
  }
  return [...rest, ...phoneOff];
}

/// Next free task id for a user-added task.
int nextTaskId(List<Map<String, dynamic>> tasks) {
  return tasks.fold<int>(0, (max, task) {
    final value = (task['id'] as num?)?.toInt() ?? 0;
    return value > max ? value : max;
  }) +
      1;
}

/// Loads the user's plan, seeding it from the bundled [templateJson]
/// on first run. The plan itself lives in local storage; edits never
/// touch the bundled template.
Future<List<Map<String, dynamic>>> loadPlanOrSeed(
    DatabaseHelper db, String templateJson) async {
  final stored = await db.getUserPlan();
  if (stored != null) return stored;
  final template = parsePlanTasks(templateJson);
  await db.saveUserPlan(template);
  return template;
}

/// Restores the bundled template as the user's plan in one action.
/// Only the plan is cleared — history logs, points and profile are
/// stored under separate keys and are preserved.
Future<List<Map<String, dynamic>>> resetPlanToDefaults(
    DatabaseHelper db, String templateJson) async {
  await db.clearUserPlan();
  return loadPlanOrSeed(db, templateJson);
}
