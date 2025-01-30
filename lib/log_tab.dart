import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'database_helper.dart'; // Import the DatabaseHelper class

var exercises = [
  'pranayama',
  'lower body strength',
  'yoga',
  'kickboxing',
  'upper body strength'
];
var meditations = [
  'loving kindness',
  'breath meditation',
  'body scan',
  'walking meditation',
  'eating meditation',
  'box breath'
];

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _logs = [];
  DateTime _selectedDate = DateTime.now();
  int _totalExerciseDuration = 0; // Total duration of exercises
  int _totalMeditationDuration = 0; // Total duration of meditations

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    final logs = await _dbHelper.getLogsByDate(_formatDate(_selectedDate));
    setState(() {
      _logs = logs;
      _calculateTotals(logs); // Calculate totals after fetching logs
    });
  }

  void _calculateTotals(List<Map<String, dynamic>> logs) {
    int exerciseTotal = 0;
    int meditationTotal = 0;

    // Debug: Print all logs to verify activity values
    print('Logs: $logs');

    for (final log in logs) {
      // Cast the duration to int
      final duration = log['duration'] as int;

      // Debug: Print each log's activity and duration
      print('Activity: ${log['activity']}, Duration: $duration');

      final name = log['activity'].toString().toLowerCase();

      // Case-insensitive comparison for activity
      if (exercises.contains(name)) {
        exerciseTotal += duration;
      } else if (meditations.contains(name)) {
        meditationTotal += duration;
      }
    }

    // Debug: Print calculated totals
    print('Exercise Total: $exerciseTotal, Meditation Total: $meditationTotal');

    setState(() {
      _totalExerciseDuration = exerciseTotal;
      _totalMeditationDuration = meditationTotal;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchLogs();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String formatTime(String time) {
    // Parse the time string into a DateTime object
    final dateTime = DateTime.parse(time); // Use a dummy date
    // Format the time as "hh:mm a" (e.g., 11:30 AM)
    return DateFormat('hh:mm a').format(dateTime);
  }

  String formatDuration(int seconds) {
    // Convert seconds to minutes and seconds
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    // Format as "X minutes Y seconds" (e.g., "5 minutes 30 seconds")
    return '$minutes minutes $remainingSeconds seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${_formatDate(_selectedDate)}'),
        actions: [
          IconButton(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _logs.isEmpty
                ? Center(
                    child: Text('No logs found for this date.'),
                  )
                : ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return ListTile(
                        title: Text(log['activity']),
                        subtitle: Text(
                            'Duration: ${formatDuration(log['duration'] as int)}'), // Cast duration to int
                        trailing:
                            Text(formatTime(log['time'])), // Format the time
                      );
                    },
                  ),
          ),
          // Footer to show totals
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Total Exercise',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatDuration(_totalExerciseDuration),
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Total Meditation',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatDuration(_totalMeditationDuration),
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
