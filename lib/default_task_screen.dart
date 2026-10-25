import 'micro_llm.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class DefaultTaskScreen extends StatelessWidget {
  final String taskName;
  final String taskDescription;
  final DatabaseHelper dbHelper = DatabaseHelper();

  DefaultTaskScreen({
    super.key,
    required this.taskName,
    required this.taskDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskDescription,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Log the completion once per day: repeated Done taps
                  // for the same task must not insert duplicate logs.
                  final todaysLogs = await dbHelper.getCompletedTasks();
                  final alreadyLogged = todaysLogs.any((log) =>
                      log['activity'] == taskName ||
                      log['taskname'] == taskName);
                  if (!alreadyLogged) {
                    await dbHelper.insertCompletedTask(taskName, 'general');
                    await MicroLlm().recordBehavior(taskName);
                  }
                  await AudioPlayer()
                      .play(AssetSource('sounds/tibet_bell.wav'));
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
