import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your database helper

class WorkoutCompleteDialog {
  final BuildContext context;
  final String workoutName;
  final int elapsedTime;
  //final AudioPlayer audioPlayer; // Add AudioPlayer as a parameter

  WorkoutCompleteDialog({
    required this.context,
    required this.workoutName,
    required this.elapsedTime,
    //required this.audioPlayer, // Initialize AudioPlayer
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

                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
