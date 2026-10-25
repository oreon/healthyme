import 'package:flutter/material.dart';
import 'package:healthyme/box_breathing_screen.dart';
import 'package:healthyme/database_helper.dart';
import 'package:healthyme/default_task_screen.dart';
import 'package:healthyme/diet_tab.dart';
import 'package:healthyme/journal_screen.dart';
import 'package:healthyme/lowerbody_strength.dart';

import 'package:healthyme/meditation_tab.dart';
import 'package:healthyme/plan.dart';
import 'package:healthyme/pranayama_screen.dart';
import 'package:healthyme/strength_alternation.dart';
import 'package:healthyme/yoga_screen.dart';
import 'package:healthyme/talk_to_ai_screen.dart';

import 'package:flutter/services.dart' show rootBundle;

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];
  final Map<int, bool> _completionById = {};
  int _todaysScore = 0;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
    _loadTodaysScore();
  }

  int _taskId(Map<String, dynamic> task) =>
      (task['id'] as num?)?.toInt() ?? -1;

  Future<String> _templateJson() =>
      rootBundle.loadString('assets/tasks.json');

  Future<void> _loadPlan() async {
    final plan = await loadPlanOrSeed(_dbHelper, await _templateJson());
    if (!mounted) return;
    setState(() {
      _tasks = plan;
    });
    await _refreshCompletion();
  }

  Future<void> _refreshCompletion() async {
    final completedTasks = await _dbHelper.getCompletedTasks();
    if (!mounted) return;
    setState(() {
      for (final task in _tasks) {
        _completionById[_taskId(task)] = completedTasks.any(
            (completedTask) =>
                completedTask['activity'] == task['taskname'] ||
                completedTask['taskname'] == task['taskname']);
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

  Future<void> _savePlan() => _dbHelper.saveUserPlan(_tasks);

  /// Screens that run a guided, timed session. Those sessions earn
  /// duration-based points from the points engine when they end, so
  /// completing them here must not also grant the flat untimed award.
  static const _guidedScreens = {
    'MeditationScreen',
    'ExerciseScreen',
    'YogaScreen',
    'PranayamaScreen',
  };

  Future<void> _completeTask(Map<String, dynamic> task) async {
    await _dbHelper.insertCompletedTask(task['taskname'], task['tasktype']);
    final isGuided = _guidedScreens.contains(task['screenName']);
    final newScore = isGuided
        ? await _dbHelper.getTodaysScore()
        : await _dbHelper.awardPoints(10);
    if (!mounted) return;
    setState(() {
      _completionById[_taskId(task)] = true;
      _todaysScore = newScore;
    });
  }

  TimeOfDay _timeOfDayFor(Map<String, dynamic> task) {
    final minutes = timeToMinutes(task['time'] as String?);
    if (minutes == null) return const TimeOfDay(hour: 8, minute: 0);
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  Future<void> _rescheduleTask(Map<String, dynamic> task) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDayFor(task),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final index = _tasks.indexWhere((t) => _taskId(t) == _taskId(task));
      if (index >= 0) {
        _tasks[index] = {
          ..._tasks[index],
          'time': formatHhmm(picked.hour, picked.minute),
        };
      }
    });
    await _savePlan();
  }

  Future<void> _deleteTask(Map<String, dynamic> task) async {
    setState(() {
      _tasks = _tasks.where((t) => _taskId(t) != _taskId(task)).toList();
      _completionById.remove(_taskId(task));
    });
    await _savePlan();
  }

  Future<void> _addTask() async {
    final entry = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add task'),
        children: [
          for (final item in activityLibrary)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text(item['taskname'] as String),
            ),
        ],
      ),
    );
    if (entry == null || !mounted) return;

    var name = entry['taskname'] as String;
    if (entry['screenName'] == null) {
      final controller = TextEditingController();
      final custom = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Task name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. Tidy your room'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Add'),
            ),
          ],
        ),
      );
      if (custom == null || custom.trim().isEmpty || !mounted) return;
      name = custom.trim();
    }

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (time == null || !mounted) return;

    final task = <String, dynamic>{
      'id': nextTaskId(_tasks),
      'taskname': name,
      'tasktype': entry['tasktype'],
      'time': formatHhmm(time.hour, time.minute),
      if (entry['screenName'] != null) 'screenName': entry['screenName'],
    };
    setState(() {
      _tasks = pinPhoneOffLast([..._tasks, task]);
      _completionById[_taskId(task)] = false;
    });
    await _savePlan();
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset routine to defaults?'),
        content: const Text(
            'This restores the default daily plan. Your history, points and profile are kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final plan = await resetPlanToDefaults(_dbHelper, await _templateJson());
    if (!mounted) return;
    setState(() {
      _tasks = plan;
    });
    await _refreshCompletion();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Routine reset to defaults')),
    );
  }

  void _onReorderSection(DaySection section, int oldIndex, int newIndex) {
    // Dragging happens inside one section; splice the reordered section
    // items back into their slots in the overall plan order.
    final slots = <int>[
      for (var i = 0; i < _tasks.length; i++)
        if (sectionForTime(_tasks[i]['time'] as String?) == section) i,
    ];
    final sectionTasks = [for (final i in slots) _tasks[i]];
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    final item = sectionTasks.removeAt(oldIndex);
    sectionTasks.insert(target, item);
    setState(() {
      for (var k = 0; k < slots.length; k++) {
        _tasks[slots[k]] = sectionTasks[k];
      }
      _tasks = pinPhoneOffLast(_tasks);
    });
    _savePlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit),
            tooltip: _editing ? 'Done editing' : 'Edit routine',
            onPressed: () {
              setState(() {
                _editing = !_editing;
              });
            },
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TalkToAIScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Talk to coach'),
              ),
            ),
          ),
          if (_editing)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add),
                      label: const Text('Add task'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetToDefaults,
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset to defaults'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _editing
                            ? 'No tasks in your routine. Add a task or reset to defaults.'
                            : 'No tasks for today. Tap the pencil to edit your routine.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      for (final section in DaySection.values)
                        ..._buildSection(section),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSection(DaySection section) {
    final sectionTasks = _tasks
        .where((t) => sectionForTime(t['time'] as String?) == section)
        .toList();
    if (sectionTasks.isEmpty && !_editing) return const [];

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        section.label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );

    if (!_editing) {
      return [
        header,
        for (final task in sectionTasks) _taskTile(task),
      ];
    }

    return [
      header,
      if (sectionTasks.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('No tasks'),
        )
      else
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sectionTasks.length,
          onReorder: (oldIndex, newIndex) =>
              _onReorderSection(section, oldIndex, newIndex),
          itemBuilder: (context, index) => _taskTile(
            sectionTasks[index],
            editing: true,
            sectionIndex: index,
          ),
        ),
    ];
  }

  Widget _taskTile(Map<String, dynamic> task,
      {bool editing = false, int sectionIndex = 0}) {
    final isCompleted = _completionById[_taskId(task)] ?? false;
    final overdue = isTaskOverdue(task, isCompleted, DateTime.now());
    final subtitleParts = <String>[
      if (task['time'] != null) task['time'] as String,
      task['tasktype'] as String? ?? '',
    ];
    var subtitle = subtitleParts.join(' · ');
    if (overdue) subtitle += ' · Overdue';

    return Card(
      key: editing ? ValueKey(_taskId(task)) : null,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isCompleted
          ? Colors.green[900]
          : overdue
              ? Colors.amber[900]
              : null,
      child: ListTile(
        title: Text(
          task['taskname'],
          style: TextStyle(
            color: isCompleted ? Colors.green[100] : null,
            fontWeight: isCompleted ? FontWeight.bold : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: overdue
              ? TextStyle(
                  color: Colors.amber[200], fontWeight: FontWeight.bold)
              : null,
        ),
        trailing: editing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete task',
                    onPressed: () => _deleteTask(task),
                  ),
                  ReorderableDragStartListener(
                    index: sectionIndex,
                    child: const Icon(Icons.drag_handle),
                  ),
                ],
              )
            : isCompleted
                ? Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: Icon(Icons.check_circle_outline, color: Colors.grey),
                    onPressed: () => _completeTask(task),
                  ),
        onTap: editing
            ? () => _rescheduleTask(task)
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _getScreenByName(task),
                  ),
                );
                if (!mounted) return;
                await _loadPlan();
                await _loadTodaysScore();
              },
      ),
    );
  }

  Widget _getScreenByName(dynamic task) {
    String screenName = task['screenName'] ?? "default";
    final String name = task['taskname'];
    switch (screenName) {
      case 'MeditationScreen':
        return MeditationTab();
      case 'ExerciseScreen':
        return isUpperBodyDay(DateTime.now())
            ? UpperBodyWorkoutScreen()
            : LowerBodyWorkoutScreen();
      case 'YogaScreen':
        return YogaScreen();
      case 'PranayamaScreen':
        return PranayamaScreen();
      case 'JournalScreen':
        return JournalScreen();
      case 'BoxBreathingScreen':
        return BoxBreathingScreen();
      case 'DietTab':
        return Scaffold(
          appBar: AppBar(title: Text(name)),
          body: DietTab(),
        );
      default:
        return DefaultTaskScreen(
          taskName: name,
          taskDescription: task['description'] ?? " Please do $name",
        );
    }
  }
}
