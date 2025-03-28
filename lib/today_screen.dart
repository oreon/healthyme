import 'package:flutter/material.dart';
import 'package:healthyme/database_helper.dart';
import 'package:healthyme/default_task_screen.dart';
import 'package:healthyme/journal_screen.dart';
import 'package:healthyme/lowerbody_strength.dart';

import 'package:healthyme/meditation_tab.dart';
import 'package:healthyme/pranayama_screen.dart';
import 'package:healthyme/yoga_screen.dart';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];
  final Map<int, bool> _taskCompletionStatus =
      {}; // Track completion status of tasks
  int _todaysScore = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadTodaysScore();
  }

  Future<void> _loadTasks() async {
    // Load tasks from JSON file
    String jsonString = await rootBundle.loadString('assets/tasks.json');
    List<dynamic> tasks = json.decode(jsonString);

    // Load completed tasks from the database
    List<Map<String, dynamic>> completedTasks =
        await _dbHelper.getCompletedTasks();

    setState(() {
      _tasks = tasks.cast<Map<String, dynamic>>();

      // Initialize completion status for all tasks
      for (int i = 0; i < _tasks.length; i++) {
        final task = _tasks[i];
        // Check if the task is in the completedTasks list
        final isCompleted = completedTasks.any(
            (completedTask) => completedTask['taskname'] == task['taskname']);
        // print(
        //   '$isCompleted ${task['taskname']}',
        // );
        _taskCompletionStatus[i] = isCompleted; // Set completion status
      }
    });
  }

  Future<void> _loadTodaysScore() async {
    final score = 0; //await _dbHelper.getTodaysScore();
    setState(() {
      _todaysScore = score;
    });
  }

  Future<void> _completeTask(int index) async {
    final task = _tasks[index];
    await _dbHelper.insertCompletedTask(task['taskname'], task['tasktype']);
    final newScore = _todaysScore + 10;
    //await _dbHelper.updateTodaysScore(newScore);
    setState(() {
      _taskCompletionStatus[index] = true; // Mark task as completed
      _todaysScore = newScore; // Update the score
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Today\'s Score: $_todaysScore',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isCompleted = _taskCompletionStatus[index] ?? false;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isCompleted
                      ? Colors.grey[200]
                      : null, // Gray out if completed
                  child: ListTile(
                    title: Text(
                      task['taskname'],
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.grey
                            : Colors.green, // Gray out text if completed
                      ),
                    ),
                    subtitle: Text('Type: ${task['tasktype']}'),
                    trailing: isCompleted
                        ? Icon(Icons.check_circle,
                            color: Colors.green) // Green tick if completed
                        : IconButton(
                            icon: Icon(Icons.check_circle_outline,
                                color: Colors.grey),
                            onPressed: () => _completeTask(index),
                          ),
                    onTap: () => {
                      // if (task['screenName'] != null)
                      //{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _getScreenByName(task),
                        ),
                      )
                      //}
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getScreenByName(dynamic task) {
    String screenName = task['screenName'] ?? "default";
    final String name = task['taskname'];

    // Get the current day of the year
    DateTime now = DateTime.now();
    int dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    // Check if the day of the year is even or odd
    bool isEvenDay = dayOfYear % 2 == 0;

    switch (screenName) {
      case 'MeditationScreen':
        return MeditationTab();
      case 'ExerciseScreen':
        // Return LowerBodyWorkoutScreen on even days, UpperBodyWorkoutScreen on odd days
        return isEvenDay ? LowerBodyWorkoutScreen() : UpperBodyWorkoutScreen();
      case 'YogaScreen':
        return YogaScreen();
      case 'PranayamaScreen':
        return PranayamaScreen();
      case 'JournalScreen':
        return JournalScreen();
      default:
        return DefaultTaskScreen(
          taskName: name,
          taskDescription: task['description'] ?? " Please do $name",
        );
    }
  }
}
