import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'completion.dart';
import 'database_helper.dart'; // Import your database helper

/// The completion moment shown when a guided session ends: "Well
/// done!", the points the session earned, an encouragement line, the
/// optional five-face feeling + written reflection, and a Share
/// action that opens the native share sheet directly.
class WorkoutCompleteDialog {
  final BuildContext context;
  final String workoutName;
  final int elapsedTime;

  /// Points this session earned — the same figure the points engine
  /// credited, so the dialog, the header total and the stored points
  /// event all agree.
  final int pointsEarned;

  /// Encouragement line for the activity kind (see completion.dart).
  final String encouragement;

  /// How the session ended: 'full', 'ended_early' or 'with_skips'.
  final String completionKind;

  WorkoutCompleteDialog({
    required this.context,
    required this.workoutName,
    required this.elapsedTime,
    this.pointsEarned = 0,
    this.encouragement = physicalEncouragement,
    this.completionKind = 'full',
  });

  void show() {
    final commentController = TextEditingController();
    String? selectedFace;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Well done!'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(encouragement, textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Text(
                      'You earned $pointsEarned points for your '
                      '$workoutName session.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total Duration: ${elapsedTime ~/ 60}:${(elapsedTime % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('How do you feel now?'),
                    const SizedBox(height: 8),
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
                        labelText: 'Reflection (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share',
                  onPressed: () => _share(
                      dialogContext, selectedFace, commentController.text),
                ),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await DatabaseHelper().logCompletion(
                      activity: workoutName,
                      duration: elapsedTime,
                      comments: commentController.text.trim(),
                      feeling: selectedFace,
                      completionKind: completionKind,
                      points: pointsEarned,
                    );

                    navigator.pop(); // Close the dialog
                    navigator.pop(); // Back to the previous screen
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Opens the native share sheet directly with the completion text.
  /// Sharing is voluntary and never touches the saved record; if the
  /// share sheet is unavailable, the text is copied to the clipboard
  /// instead and the user is told.
  Future<void> _share(
      BuildContext dialogContext, String? face, String reflection) async {
    final text = buildShareText(
      activityName: workoutName,
      points: pointsEarned,
      feelingFace: face,
      reflection: reflection,
    );
    try {
      await Share.share(text);
    } catch (_) {
      try {
        await Clipboard.setData(ClipboardData(text: text));
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            const SnackBar(content: Text('Copied')),
          );
        }
      } catch (_) {
        // No share sheet and no clipboard: nothing more we can do.
      }
    }
  }
}
