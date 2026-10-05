import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your database helper

class WorkoutCompleteDialog {
  final BuildContext context;
  final String workoutName;
  final int elapsedTime;

  WorkoutCompleteDialog({
    required this.context,
    required this.workoutName,
    required this.elapsedTime,
  });

  void show() {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Workout Complete!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Great job! You’ve finished your $workoutName session.'),
                const SizedBox(height: 10),
                Text(
                  'Total Duration: ${elapsedTime ~/ 60}:${(elapsedTime % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'How do you feel now?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String comment = commentController.text.trim();
                if (comment.isNotEmpty) {
                  await DatabaseHelper()
                      .logActivity(workoutName, elapsedTime, comment);
                } else {
                  await DatabaseHelper()
                      .logActivity(workoutName, elapsedTime, '');
                }
                final current = await DatabaseHelper().getTodaysScore();
                await DatabaseHelper().updateTodaysScore(current + 10);

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
