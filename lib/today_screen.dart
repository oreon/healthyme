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
  final Map<int, bool> _taskCompletionStatus = {};
  int _todaysScore = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadTodaysScore();
  }

  Future<void> _loadTasks() async {
    String jsonString = await rootBundle.loadString('assets/tasks.json');
    List<dynamic> tasks = json.decode(jsonString);
    List<Map<String, dynamic>> completedTasks =
        await _dbHelper.getCompletedTasks();

    setState(() {
      _tasks = tasks.cast<Map<String, dynamic>>();
      for (int i = 0; i < _tasks.length; i++) {
        final task = _tasks[i];
        final isCompleted = completedTasks.any((completedTask) =>
            completedTask['activity'] == task['taskname'] ||
            completedTask['taskname'] == task['taskname']);
        _taskCompletionStatus[i] = isCompleted;
      }
    });
  }

  Future<void> _loadTodaysScore() async {
    final score = await _dbHelper.getTodaysScore();
    if (!mounted) return;
    setState(() {
      _todaysScore = score;
    });
  }

  Future<void> _completeTask(int index) async {
    final task = _tasks[index];
    await _dbHelper.insertCompletedTask(task['taskname'], task['tasktype']);
    final newScore = _todaysScore + 10;
    await _dbHelper.updateTodaysScore(newScore);
    if (!mounted) return;
    setState(() {
      _taskCompletionStatus[index] = true;
      _todaysScore = newScore;
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
                  color: isCompleted ? Colors.grey[200] : null,
                  child: ListTile(
                    title: Text(
                      task['taskname'],
                      style: TextStyle(
                        color: isCompleted ? Colors.grey : Colors.green,
                      ),
                    ),
                    subtitle: Text('Type: ${task['tasktype']}'),
                    trailing: isCompleted
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                            icon: Icon(Icons.check_circle_outline,
                                color: Colors.grey),
                            onPressed: () => _completeTask(index),
                          ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _getScreenByName(task),
                        ),
                      );
                      if (!mounted) return;
                      await _loadTasks();
                      await _loadTodaysScore();
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
    DateTime now = DateTime.now();
    int dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    bool isEvenDay = dayOfYear % 2 == 0;
    switch (screenName) {
      case 'MeditationScreen':
        return MeditationTab();
      case 'ExerciseScreen':
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
