import 'package:flutter/material.dart';
import 'dart:convert';
import 'database_helper.dart';
import 'package:flutter/services.dart' show rootBundle;

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadTotalScore();
  }

  Future<void> _loadTasks() async {
    String jsonString = await rootBundle.loadString('assets/tasks.json');
    List<dynamic> tasks = json.decode(jsonString);
    setState(() {
      _tasks = tasks.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _loadTotalScore() async {
    int score = await _dbHelper.getTotalScore();
    setState(() {
      _totalScore = score;
    });
  }

  Future<void> _completeTask(int index) async {
    final task = _tasks[index];
    await _dbHelper.insertCompletedTask(task['taskname'], task['tasktype']);
    await _loadTotalScore(); // Refresh the total score
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
              'Total Score: $_totalScore',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(task['taskname']),
                    subtitle: Text('Type: ${task['tasktype']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _completeTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
