import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'session_draft.dart';

/// Browser-compatible local-first storage for logs and scores.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static const _logsKey = 'healthyme.activity_logs';
  static const _scoresKey = 'healthyme.scores';
  static const _pointsEventsKey = 'healthyme.points_events';
  static const _sessionDraftsKey = 'healthyme.session_drafts';
  static const _planKey = 'healthyme.daily_plan';
  SharedPreferences? _preferences;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _read(String key) async {
    final raw = (await _prefs).getString(key);
    if (raw == null) return <Map<String, dynamic>>[];
    try {
      final value = jsonDecode(raw);
      return value is List
          ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : <Map<String, dynamic>>[];
    } on FormatException {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _write(String key, List<Map<String, dynamic>> value) async {
    await (await _prefs).setString(key, jsonEncode(value));
  }

  String getTodaysDate() => DateTime.now().toIso8601String().split('T').first;

  Future<int> insertActivityLog({
    String? date,
    String? activity,
    String? tasktype,
    String? sentiment,
    int? duration,
    String? comments,
    String? feeling,
    String? completionKind,
    int? points,
  }) async {
    final logs = await _read(_logsKey);
    final id = logs.fold<int>(0, (max, row) {
      final value = (row['id'] as num?)?.toInt() ?? 0;
      return value > max ? value : max;
    }) + 1;
    logs.add({
      'id': id,
      'date': date ?? getTodaysDate(),
      'activity': activity,
      'tasktype': tasktype,
      'sentiment': sentiment,
      'duration': duration,
      'comments': comments,
      if (feeling != null) 'feeling': feeling,
      if (completionKind != null) 'completion_kind': completionKind,
      if (points != null) 'points': points,
      'time': DateTime.now().toIso8601String(),
    });
    await _write(_logsKey, logs);
    return id;
  }

  Future<void> logActivity(String activity, int duration, String comments) =>
      insertActivityLog(activity: activity, duration: duration, comments: comments);

  /// Records a finished guided session: its practiced duration, the
  /// points it earned, how it ended ([completionKind]: 'full',
  /// 'ended_early' or 'with_skips') and the user's optional feeling
  /// face + written reflection.
  Future<void> logCompletion({
    required String activity,
    required int duration,
    String comments = '',
    String? feeling,
    String? completionKind,
    int? points,
  }) =>
      insertActivityLog(
        activity: activity,
        duration: duration,
        comments: comments,
        feeling: feeling,
        completionKind: completionKind,
        points: points,
      );

  /// Updates the feeling face and/or reflection stored on an existing
  /// log entry, so completion feedback stays editable afterwards.
  /// Returns false when no entry has [id].
  Future<bool> updateLogFeedback(
    int id, {
    String? feeling,
    bool clearFeeling = false,
    String? comments,
  }) async {
    final logs = await _read(_logsKey);
    final index = logs.indexWhere((row) => row['id'] == id);
    if (index < 0) return false;
    if (clearFeeling) {
      logs[index].remove('feeling');
    } else if (feeling != null) {
      logs[index]['feeling'] = feeling;
    }
    if (comments != null) logs[index]['comments'] = comments;
    await _write(_logsKey, logs);
    return true;
  }

  Future<List<Map<String, dynamic>>> getCompletedTasks({String? date}) async {
    final target = date ?? getTodaysDate();
    final logs = await _read(_logsKey);
    return logs.where((row) => (row['date'] as String? ?? '').startsWith(target)).toList();
  }

  Future<List<Map<String, dynamic>>> getLogsByDate(String date) async {
    final logs = await _read(_logsKey);
    return logs.where((row) => row['date'] == date).toList();
  }

  Future<void> insertJournalEntry(String entry, String sentiment) =>
      insertActivityLog(activity: 'journal', comments: entry, sentiment: sentiment);

  Future<void> insertCompletedTask(String taskname, String tasktype) =>
      insertActivityLog(activity: taskname, tasktype: tasktype, comments: '');

  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final logs = await _read(_logsKey);
    return logs.where((row) => row['activity'] == 'journal').toList();
  }

  Future<int> deleteJournalEntry(int id) async {
    final logs = await _read(_logsKey);
    final oldLength = logs.length;
    logs.removeWhere((row) => row['id'] == id && row['activity'] == 'journal');
    await _write(_logsKey, logs);
    return oldLength - logs.length;
  }

  Future<int> getTodaysScore() async {
    final scores = await _read(_scoresKey);
    return scores.where((row) => row['date'] == getTodaysDate()).fold<int>(
      0,
      (total, row) => total + ((row['score'] as num?)?.toInt() ?? 0),
    );
  }

  Future<void> updateTodaysScore(int score) async {
    final scores = await _read(_scoresKey);
    final today = getTodaysDate();
    scores.removeWhere((row) => row['date'] == today && row['activity'] == 'daily');
    scores.add({'date': today, 'activity': 'daily', 'score': score});
    await _write(_scoresKey, scores);
  }

  Future<void> logScore(String date, String activity, int score) async {
    final scores = await _read(_scoresKey);
    scores.add({'date': date, 'activity': activity, 'score': score});
    await _write(_scoresKey, scores);
  }

  /// Adds [points] to today's score as a new score event and returns the
  /// new daily total (the sum of all of today's score events).
  Future<int> awardPoints(int points, {String activity = 'daily'}) async {
    await logScore(getTodaysDate(), activity, points);
    return getTodaysScore();
  }

  /// Credits a guided session's points under its unique [sessionKey].
  ///
  /// Idempotent: the session's credited total is stored, and re-awarding
  /// the same session (e.g. resume + re-save) only adds the difference
  /// between [totalPoints] and what was already credited, so a session
  /// can never be counted twice. Returns the points added by this call.
  Future<int> awardSessionPoints(String sessionKey, int totalPoints) async {
    final events = await _read(_pointsEventsKey);
    final index =
        events.indexWhere((row) => row['session_key'] == sessionKey);
    final alreadyCredited = index < 0
        ? 0
        : (events[index]['points'] as num?)?.toInt() ?? 0;
    if (index < 0) {
      events.add({
        'session_key': sessionKey,
        'points': totalPoints,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      events[index]['points'] = totalPoints;
    }
    await _write(_pointsEventsKey, events);

    final delta = totalPoints - alreadyCredited;
    if (delta != 0) {
      await logScore(getTodaysDate(), 'session', delta);
    }
    return delta;
  }

  /// Saves (or replaces) the in-progress draft for a session family +
  /// identity, e.g. kind 'workout', identity 'Yoga'.
  Future<void> saveSessionDraft(SessionDraft draft) async {
    final drafts = await _read(_sessionDraftsKey);
    drafts.removeWhere((row) =>
        row['kind'] == draft.kind && row['identity'] == draft.identity);
    drafts.add(draft.toJson());
    await _write(_sessionDraftsKey, drafts);
  }

  /// The resumable draft for a session family + identity, or null.
  /// Drafts are only resumable on the day they were saved.
  Future<SessionDraft?> getSessionDraft(String kind, String identity) async {
    final drafts = await _read(_sessionDraftsKey);
    for (final row in drafts) {
      if (row['kind'] == kind && row['identity'] == identity) {
        final draft = SessionDraft.fromJson(row);
        return draft.date == getTodaysDate() ? draft : null;
      }
    }
    return null;
  }

  /// Discards the draft for a session family + identity (on completion
  /// or when the user chooses to start over).
  Future<void> clearSessionDraft(String kind, String identity) async {
    final drafts = await _read(_sessionDraftsKey);
    drafts.removeWhere(
        (row) => row['kind'] == kind && row['identity'] == identity);
    await _write(_sessionDraftsKey, drafts);
  }

  /// The user's daily plan (tasks, times and order), or null when no
  /// plan has been stored yet — first run seeds it from the bundled
  /// template. Kept under its own key so plan edits and resets never
  /// touch history logs, scores or profile data.
  Future<List<Map<String, dynamic>>?> getUserPlan() async {
    final raw = (await _prefs).getString(_planKey);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      return value is List
          ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveUserPlan(List<Map<String, dynamic>> plan) async {
    await (await _prefs).setString(_planKey, jsonEncode(plan));
  }

  /// Removes only the stored plan; the next load re-seeds it from the
  /// bundled template.
  Future<void> clearUserPlan() async {
    await (await _prefs).remove(_planKey);
  }

  Future<int> getTotalScore() async {
    final scores = await _read(_scoresKey);
    return scores.fold<int>(
      0,
      (total, row) => total + ((row['score'] as num?)?.toInt() ?? 0),
    );
  }
}
