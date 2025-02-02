import 'package:flutter/material.dart';
import 'package:healthyme/lowerbody_strength.dart';
import 'package:healthyme/meditation_screen.dart';
import 'package:healthyme/meditation_tab.dart';
import 'package:healthyme/yoga_screen.dart';
import 'dart:convert';
import 'database_helper.dart';
import 'package:flutter/services.dart' show rootBundle;

class TodayScreen extends StatefulWidget {
  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];
  Map<int, bool> _taskCompletionStatus = {}; // Track completion status of tasks
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<int> getTotalScore() async {
    List<Map<String, dynamic>> tasks = await _dbHelper.getCompletedTasks();
    return tasks.length * 10; // 10 points per task
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
        final isCompleted = completedTasks.any((completedTask) =>
            completedTask['taskname'] == task['taskname'] &&
            completedTask['tasktype'] == task['tasktype']);
        _taskCompletionStatus[i] = isCompleted; // Set completion status
      }
    });
  }

  Future<void> _completeTask(int index) async {
    final task = _tasks[index];
    await _dbHelper.insertCompletedTask(task['taskname'], task['tasktype']);
    setState(() {
      _taskCompletionStatus[index] = true; // Mark task as completed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Score:$getTotalScore()'),
      ),
      body: Column(
        children: [
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
                              : Colors.black, // Gray out text if completed
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
                      onTap: () {
                        if (task['screenName'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  _getScreenByName(task['screenName']),
                            ),
                          );
                        }
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getScreenByName(String screenName) {
    switch (screenName) {
      case 'MeditationScreen':
        return MeditationTab();
      case 'ExerciseScreen':
        return LowerBodyWorkoutScreen();
      case 'Yoga':
        return YogaScreen();
      default:
        return Scaffold(
          appBar: AppBar(title: Text('Screen Not Found')),
          body: Center(child: Text('Screen not found for $screenName')),
        );
    }
  }
}

// class _TodayScreenState extends State<TodayScreen> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   List<Map<String, dynamic>> _tasks = [];
//   int _totalScore = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadTasks();
//     _loadTotalScore();
//   }

//   Future<void> _loadTasks() async {
//     String jsonString = await rootBundle.loadString('assets/tasks.json');
//     List<dynamic> tasks = json.decode(jsonString);
//     setState(() {
//       _tasks = tasks.cast<Map<String, dynamic>>();
//     });
//   }

//   Future<void> _loadTotalScore() async {
//     int score = await _dbHelper.getTotalScore();
//     setState(() {
//       _totalScore = score;
//     });
//   }

//   Future<void> _completeTask(int index) async {
//     final task = _tasks[index];
//     await _dbHelper.insertCompletedTask(task['taskname'], task['tasktype']);
//     await _loadTotalScore(); // Refresh the total score
//   }

//   // Helper method to get the screen by name

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Today'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Total Score: $_totalScore',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _tasks.length,
//               itemBuilder: (context, index) {
//                 final task = _tasks[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: ListTile(
//                     title: Text(task['taskname']),
//                     subtitle: Text('Type: ${task['tasktype']}'),
//                     trailing: IconButton(
//                       icon: Icon(Icons.check, color: Colors.green),
//                       onPressed: () => _completeTask(index),
//                     ),
//                     onTap: () {
//                       if (task['screenName'] != null) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 _getScreenByName(task['screenName']),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void main() {
//   runApp(HabitMakerApp());
// }
