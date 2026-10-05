import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Browser-compatible local-first storage for logs and scores.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static const _logsKey = 'healthyme.activity_logs';
  static const _scoresKey = 'healthyme.scores';
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
      'time': DateTime.now().toIso8601String(),
    });
    await _write(_logsKey, logs);
    return id;
  }

  Future<void> logActivity(String activity, int duration, String comments) =>
      insertActivityLog(activity: activity, duration: duration, comments: comments);

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

  Future<int> getTotalScore() async {
    final scores = await _read(_scoresKey);
    return scores.fold<int>(
      0,
      (total, row) => total + ((row['score'] as num?)?.toInt() ?? 0),
    );
  }
}
