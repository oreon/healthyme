import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperOld {
  static final DatabaseHelperOld _instance = DatabaseHelperOld._internal();
  static Database? _database;

  factory DatabaseHelperOld() {
    return _instance;
  }

  DatabaseHelperOld._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("old  $oldVersion,  new : $newVersion");
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE journal ADD COLUMN sentiment TEXT');
    // }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE activity_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL, -- Date of the activity
      activity TEXT, -- General activity or task name
      tasktype TEXT, -- Task type (optional)
      sentiment TEXT, -- Sentiment (optional)
      duration INTEGER, -- Duration (optional)
      comments TEXT -- Comments (optional)
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
        date TEXT NOT NULL, 
        entry TEXT NOT NULL,
        sentiment TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE completed_tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskname TEXT,
        tasktype TEXT,
        date TEXT
      )
    ''');
  }

  // Future<List<Map<String, dynamic>>> getCompletedTasks({String? date}) async {
  //   Database db = await database;
  //   final String targetDate = date ?? getTodaysDate();

  //   return await db.query(
  //     'completed_tasks',
  //     where: 'date = ?',
  //     whereArgs: [date],
  //     orderBy: 'date DESC',
  //   );
  // }

//   Usage
//   final todayTasks = await dbHelper.getCompletedTasks();
// Get tasks for specific date
// final specificDateTasks = await dbHelper.getCompletedTasks(
//   date: DateTime(2023, 10, 30)
// );
  Future<List<Map<String, dynamic>>> getCompletedTasks({String? date}) async {
    Database db = await database;
    final String targetDate =
        date ?? DateTime.now().toIso8601String().split('T')[0];
    ;

    // Query tasks for today's date
    return await db.query(
      'completed_tasks',
      where: 'date LIKE ?', // Match tasks with today's date
      whereArgs: [
        '$targetDate%'
      ], // Use wildcard to match any time on today's date
      orderBy: 'date DESC',
    );
  }

  Future<int> getTotalScore() async {
    Database db = await database;
    List<Map<String, dynamic>> tasks = await db.query('completed_tasks');
    return tasks.length * 10; // 10 points per task
  }

  Future<int> getTotalMeditationTime(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(duration) as total FROM meditation_logs WHERE date = ?',
      [date],
    );
    return result.first['total'] as int? ?? 0; // Return 0 if no logs exist
  }

  Future<int> insertActivityLog({
    required String date,
    String? activity, // For general logs or task name
    String? tasktype, // For tasks (optional)
    String? sentiment, // For journal (optional)
    int? duration, // For general logs (optional)
    String? comments, // For general logs (optional)
  }) async {
    final db = await database;
    return await db.insert('activity_logs', {
      'date': date,
      'activity': activity,
      'tasktype': tasktype,
      'sentiment': sentiment,
      'duration': duration,
      'comments': comments,
    });
  }

  // Future<int> getTotalScore(String date) async {
  //   final db = await database;
  //   final result = await db.rawQuery(
  //     'SELECT SUM(score) as total FROM scores WHERE date = ?',
  //     [date],
  //   );
  //   return result.first['total'] as int? ?? 0;
  // }

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

  String getTodaysDate() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  Future<void> logActivity(
      String activity, int duration, String comments) async {
    final db = await database;
    final date = getTodaysDate();
    await db.insert('gen_logs', {
      'date': date,
      'activity': activity,
      'comments': comments,
      'duration': duration,
      'time': DateTime.now().toIso8601String(), // Add timestamp
    });
  }

  Future<int> insertJournalEntry(String entry, String sentiment) async {
    Database db = await database;
    return await db.insert(
      'journal',
      {
        'entry': entry,
        'date': DateTime.now().toIso8601String(),
        'sentiment': sentiment,
      },
    );
  }

  Future<int> insertCompletedTask(String taskname, String tasktype) async {
    Database db = await database;
    return await db.insert(
      'completed_tasks',
      {
        'taskname': taskname,
        'tasktype': tasktype,
        'date': getTodaysDate(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    Database db = await database;
    return await db.query('journal', orderBy: 'date DESC');
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

  Future<int> getTodaysScore() async {
    Database db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.query(
      'scores',
      where: 'date = ?',
      whereArgs: [today],
    );
    if (result.isEmpty) return 0;
    return result.first['score'] as int;
  }

  Future<void> updateTodaysScore(int score) async {
    Database db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final existingScore = await db.query(
      'scores',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (existingScore.isEmpty) {
      await db.insert(
        'scores',
        {
          'date': today,
          'score': score,
        },
      );
    } else {
      await db.update(
        'scores',
        {
          'score': score,
        },
        where: 'date = ?',
        whereArgs: [today],
      );
    }
  }
}
