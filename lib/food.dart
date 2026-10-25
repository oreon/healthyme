import 'package:intl/intl.dart';

/// Pure models and derivations for food records: the "Snapshot your
/// food" photo diary, the derived eating window and caffeine entries.
///
/// Nothing here touches storage or plugins; [DatabaseHelper] persists
/// these shapes and the Diet tab renders them.

/// Meal categories a food entry can belong to. Meal logs written by the
/// Diet tab use exactly these names as their activity, and food
/// snapshots pick one of them too.
const List<String> mealCategories = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

/// Whether an activity-log activity name counts as eating (a meal or a
/// snack) for eating-window derivation. Case-insensitive.
bool isMealActivity(String? activity) {
  if (activity == null) return false;
  final name = activity.trim().toLowerCase();
  return mealCategories.any((meal) => meal.toLowerCase() == name);
}

/// The meal category that makes sense as the default for a snapshot
/// taken at [time]: morning → Breakfast, midday → Lunch, afternoon →
/// Snack, evening → Dinner.
String defaultMealForTime(DateTime time) {
  final hour = time.hour;
  if (hour < 11) return 'Breakfast';
  if (hour < 15) return 'Lunch';
  if (hour < 18) return 'Snack';
  return 'Dinner';
}

/// One photo-diary entry: a picture of something eaten, kept on the
/// device (no upload, no analysis).
class FoodSnapshot {
  /// Stable id (the capture time in milliseconds since epoch).
  final String id;

  /// Path of the image file inside the app's documents directory
  /// (`food_photos/…`). The record stores the path; the file lives on
  /// disk, so entries survive app restarts.
  final String photoPath;

  /// One of [mealCategories].
  final String meal;

  /// When the food was recorded (the real capture/entry timestamp).
  final DateTime capturedAt;

  /// Id of the companion activity-log row, so the entry also shows in
  /// the Log/History view and can be removed together with it.
  final int? logId;

  const FoodSnapshot({
    required this.id,
    required this.photoPath,
    required this.meal,
    required this.capturedAt,
    this.logId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'photo_path': photoPath,
        'meal': meal,
        'captured_at': capturedAt.toIso8601String(),
        if (logId != null) 'log_id': logId,
      };

  factory FoodSnapshot.fromJson(Map<String, dynamic> json) => FoodSnapshot(
        id: json['id']?.toString() ?? '',
        photoPath: json['photo_path'] as String? ?? '',
        meal: json['meal'] as String? ?? 'Snack',
        capturedAt:
            DateTime.tryParse(json['captured_at'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
        logId: (json['log_id'] as num?)?.toInt(),
      );

  FoodSnapshot copyWith({int? logId}) => FoodSnapshot(
        id: id,
        photoPath: photoPath,
        meal: meal,
        capturedAt: capturedAt,
        logId: logId ?? this.logId,
      );

  /// Local calendar date (yyyy-mm-dd) the snapshot belongs to.
  String get date =>
      '${capturedAt.year}-${capturedAt.month.toString().padLeft(2, '0')}-${capturedAt.day.toString().padLeft(2, '0')}';
}

/// A quick caffeine log: coffee or tea, a cup count and a timestamp.
class CaffeineEntry {
  static const String coffee = 'coffee';
  static const String tea = 'tea';

  /// [coffee] or [tea].
  final String type;

  /// Number of cups (at least 1).
  final int cups;

  /// When the entry was logged.
  final DateTime timestamp;

  CaffeineEntry({
    required this.type,
    required this.cups,
    required this.timestamp,
  }) : assert(type == coffee || type == tea),
       assert(cups >= 1);

  /// Activity name used in the activity log ('Coffee' / 'Tea').
  String get activityLabel => type == coffee ? 'Coffee' : 'Tea';

  /// Human-readable summary, e.g. 'Coffee · 2 cups' / 'Tea · 1 cup'.
  String get displayLabel =>
      '$activityLabel · $cups ${cups == 1 ? 'cup' : 'cups'}';

  Map<String, dynamic> toJson() => {
        'type': type,
        'cups': cups,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CaffeineEntry.fromJson(Map<String, dynamic> json) => CaffeineEntry(
        type: json['type'] as String? ?? coffee,
        cups: (json['cups'] as num?)?.toInt() ?? 1,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

/// The span between the first and last eating events of a day.
class EatingWindow {
  final DateTime first;
  final DateTime last;

  const EatingWindow({required this.first, required this.last});

  Duration get duration => last.difference(first);

  static final _timeFormat = DateFormat('HH:mm');

  /// '11 h 37 min', '45 min', or '0 min' for a zero-length window.
  static String formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours > 0) return '$hours h $minutes min';
    return '$minutes min';
  }

  /// e.g. 'Eating window today: 08:05 – 19:42 (11 h 37 min)'. With a
  /// single entry the window is just that time: '… 08:05 (0 min)'.
  String describe({String dayLabel = 'today'}) {
    final start = _timeFormat.format(first);
    if (first == last) {
      return 'Eating window $dayLabel: $start (${formatDuration(duration)})';
    }
    final end = _timeFormat.format(last);
    return 'Eating window $dayLabel: $start – $end (${formatDuration(duration)})';
  }
}

/// Derives the day's eating window from eating-event timestamps
/// (meal + snack logs and food snapshots). Returns null when there are
/// no events; a single event yields a zero-length window at that time.
/// Input order does not matter.
EatingWindow? deriveEatingWindow(Iterable<DateTime> eventTimes) {
  DateTime? first;
  DateTime? last;
  for (final time in eventTimes) {
    if (first == null || time.isBefore(first)) first = time;
    if (last == null || time.isAfter(last)) last = time;
  }
  if (first == null || last == null) return null;
  return EatingWindow(first: first, last: last);
}

/// Eating-event timestamps from a day's activity-log rows: rows whose
/// activity is a meal/snack, using their real recorded `time`.
List<DateTime> mealTimesFromLogs(List<Map<String, dynamic>> logs) {
  final times = <DateTime>[];
  for (final log in logs) {
    if (!isMealActivity(log['activity'] as String?)) continue;
    final parsed = DateTime.tryParse(log['time'] as String? ?? '');
    if (parsed != null) times.add(parsed);
  }
  return times;
}
