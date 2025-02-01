import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        food TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS scores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      activity TEXT NOT NULL,
      score INTEGER NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS meditation_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      duration INTEGER NOT NULL,
      time TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS gen_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      duration INTEGER NOT NULL,
      activity TEXT NOT NULL,
      comments TEXT NOT NULL,
      time TEXT NOT NULL
    )
  ''');

    await db.execute('''
      CREATE TABLE  IF NOT EXISTS journal(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS workout_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      duration INTEGER NOT NULL,
      exercises TEXT NOT NULL,
      sets INTEGER NOT NULL,
      time TEXT NOT NULL
    )
  ''');
  }

  Future<int> getTotalMeditationTime(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(duration) as total FROM meditation_logs WHERE date = ?',
      [date],
    );
    return result.first['total'] as int? ?? 0; // Return 0 if no logs exist
  }

  Future<int> getTotalScore(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(score) as total FROM scores WHERE date = ?',
      [date],
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> getLogsByDate(String date) async {
    final db = await database;
    return await db.query(
      'gen_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<List<Map<String, dynamic>>> getFoodLogs(String date) async {
    final db = await database;
    final result = await db.query(
      'food_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((log) {
      return {
        'details': '${log['meal_type']}: ${log['food']}',
        'time': 'Logged at ${log['date']}',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getExerciseLogs(String date) async {
    final db = await database;
    final result = await db.query(
      'workout_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((log) {
      return {
        'details':
            'Exercises: ${log['exercises']}, Sets: ${log['sets']}, Duration: ${log['duration']} minutes',
        'time': 'Completed at ${log['date']}',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getMeditationLogs(String date) async {
    final db = await database;
    final result = await db.query(
      'meditation_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((log) {
      return {
        'details': 'Duration: ${log['duration']} minutes',
        'time': 'Completed at ${log['date']}',
      };
    }).toList();
  }

  Future<void> logActivity(
      String activity, int duration, String comments) async {
    final db = await database;
    final date = DateTime.now().toIso8601String().split('T').first;
    await db.insert('gen_logs', {
      'date': date,
      'activity': activity,
      'comments': comments,
      'duration': duration,
      'time': DateTime.now().toIso8601String(), // Add timestamp
    });
  }

  Future<int> insertJournalEntry(String entry) async {
    Database db = await database;
    return await db.insert(
      'journal',
      {
        'entry': entry,
        'date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    Database db = await database;
    return await db.query('journal', orderBy: 'date DESC');
  }

  Future<void> logFood(String date, String mealType, String food) async {
    final db = await database;
    await db.insert('food_logs', {
      'date': date,
      'meal_type': mealType,
      'food': food,
      'time': DateTime.now().toIso8601String(), // Add timestamp
    });
  }

  Future<void> logScore(String date, String activity, int score) async {
    final db = await database;
    await db.insert('scores', {
      'date': date,
      'activity': activity,
      'score': score,
    });
  }

  Future<void> logWorkout(
      String date, int duration, String exercises, int sets) async {
    final db = await database;
    await db.insert('workout_logs', {
      'date': date,
      'duration': duration,
      'exercises': exercises,
      'sets': sets,
      'time': DateTime.now().toIso8601String(), // Add timestamp
    });
  }

  Future<void> logMeditation(String date, int duration) async {
    final db = await database;
    await db.insert('meditation_logs', {
      'date': date,
      'duration': duration,
      'time': DateTime.now().toIso8601String(), // Add timestamp
    });
  }

  Future<int> deleteJournalEntry(int id) async {
    Database db = await database;
    return await db.delete('journal', where: 'id = ?', whereArgs: [id]);
  }
}
