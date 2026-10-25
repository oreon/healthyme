import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'completion.dart'; // Feeling faces for feedback editing
import 'database_helper.dart'; // Import the DatabaseHelper class

var exercises = [
  'pranayama',
  'lower body workout',
  'upper body workout',
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
      final duration = (log['duration'] ?? 0) as int;

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

  String _completionKindLabel(String kind) {
    switch (kind) {
      case 'full':
        return 'Completed in full';
      case 'ended_early':
        return 'Ended early';
      case 'with_skips':
        return 'Completed with skips';
      default:
        return kind;
    }
  }

  /// Lets the user revise the feeling face and reflection stored on a
  /// completion entry, updating the record in place.
  Future<void> _editFeedback(Map<String, dynamic> log) async {
    String? selectedFace = log['feeling'] as String?;
    final commentController =
        TextEditingController(text: (log['comments'] as String?) ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit feedback'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: feelingFaces.map((face) {
                        final selected = face == selectedFace;
                        return InkWell(
                          onTap: () => setState(() {
                            selectedFace = selected ? null : face;
                          }),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? Colors.green.withValues(alpha: 0.25)
                                  : null,
                              border: Border.all(
                                color: selected
                                    ? Colors.green
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(face,
                                style: const TextStyle(fontSize: 26)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Reflection',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved == true) {
      await _dbHelper.updateLogFeedback(
        (log['id'] as num).toInt(),
        feeling: selectedFace,
        clearFeeling: selectedFace == null,
        comments: commentController.text.trim(),
      );
      _fetchLogs();
    }
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
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Padding(
                          // Add padding to the Card's content
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            // Use a Column to arrange title, subtitle, and comments
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align content to the start
                            children: [
                              Row(
                                // Use a Row for title, subtitle, and time
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(log['activity'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold)), // Make activity bold
                                  Text(formatTime(log['time'])),
                                ],
                              ),
                              if (log['duration'] != null)
                                const SizedBox(height: 8), // Add some spacing
                              if (log['duration'] != null)
                                Text(
                                    'Duration: ${formatDuration((log['duration'] ?? 0) as int)}'),
                              const SizedBox(height: 8), // Add some spacing
                              if (log['comments'] != null &&
                                  log['comments'].isNotEmpty) ...[
                                // Conditional comments
                                const Text("Comments:",
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold)), // Comments label
                                Text(log['comments']),
                              ],
                              if (log['feeling'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text("Feeling: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(log['feeling'],
                                        style:
                                            const TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ],
                              if (log['completion_kind'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _completionKindLabel(
                                          log['completion_kind']),
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontStyle: FontStyle.italic),
                                    ),
                                    if (log['points'] != null)
                                      Text('${log['points']} points',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      tooltip: 'Edit feedback',
                                      onPressed: () => _editFeedback(log),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
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
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent),
                    ),
                    Text(
                      formatDuration(_totalExerciseDuration),
                      style: TextStyle(
                          fontSize: 14, color: Colors.deepPurpleAccent),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Total Meditation',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent),
                    ),
                    Text(
                      formatDuration(_totalMeditationDuration),
                      style: TextStyle(
                          fontSize: 14, color: Colors.deepPurpleAccent),
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
