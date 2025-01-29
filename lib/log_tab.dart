import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'database_helper.dart'; // Import the DatabaseHelper class

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _logs = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    final logs = await _dbHelper.getLogsByDate(_formatDate(_selectedDate));
    setState(() {
      _logs = logs;
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
      body: _logs.isEmpty
          ? Center(
              child: Text('No logs found for this date.'),
            )
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return ListTile(
                  title: Text(log['activity']),
                  subtitle: Text('Duration: ${log['duration']} seconds'),
                  trailing: Text(formatTime(log['time'])), // Format the time
                );
              },
            ),
    );
  }
}
