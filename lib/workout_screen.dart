import 'database_helper.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
}

abstract class WorkoutScreenState<T extends WorkoutScreen> extends State<T> {
  final List<Map<String, dynamic>> exercises;
  final int sets;
  final String workoutName;
  final String defaultImage;
  final int restDuration; // Rest duration in seconds

  int currentExerciseIndex = 0;
  int currentSet = 1;
  int timerSeconds = 0;
  bool isWorkPhase = true;
  bool isPaused = false;
  late Timer timer;
  final AudioPlayer audioPlayer = AudioPlayer();
  final String restImage = 'assets/images/rest.jpg';

  int totalDuration = 0;
  int elapsedTime = 0;
  late Timer workoutTimer;

  WorkoutScreenState({
    required this.exercises,
    required this.sets,
    required this.workoutName,
    required this.restDuration,
    this.defaultImage = 'assets/images/default.jpg', // Default stock image
  });

  @override
  void initState() {
    super.initState();
    timerSeconds =
        exercises[currentExerciseIndex]['duration'] as int; // Cast to int
    totalDuration = exercises.fold(
            0, (sum, exercise) => sum + (exercise['duration'] as int)) *
        sets; // Cast to int
    startWorkoutTimer();
    startTimer();
    WakelockPlus.enable();
  }

  void startWorkoutTimer() {
    workoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (timerSeconds > 0) {
            timerSeconds--;
          } else {
            if (isWorkPhase) {
              // Switch to rest phase
              isWorkPhase = false;
              timerSeconds =
                  restDuration; // Use the rest duration from the child class
              if (restDuration > 0) {
                playRestAudio();
              }
            } else {
              // Switch to next exercise
              isWorkPhase = true;
              timerSeconds = exercises[currentExerciseIndex]['duration']
                  as int; // Cast to int
              if (currentExerciseIndex < exercises.length - 1) {
                currentExerciseIndex++;
              } else {
                // Move to the next set
                if (currentSet < sets) {
                  currentSet++;
                  currentExerciseIndex = 0; // Reset to the first exercise
                } else {
                  timer.cancel(); // Stop the timer when all sets are done
                  workoutTimer.cancel();
                  //DatabaseHelper().logActivity(workoutName, totalDuration, '');
                  showWorkoutCompleteDialog();
                }
              }
              playStartAudio();
            }
          }
        });
      }
    });
  }

  void playStartAudio() async {
    await audioPlayer.play(AssetSource('sounds/start.mp3'));
  }

  void playRestAudio() async {
    await audioPlayer.play(AssetSource('sounds/rest.mp3'));
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
    if (!isPaused) {
      playStartAudio();
    }
  }

  void endWorkout() {
    timer.cancel();
    workoutTimer.cancel();

    showWorkoutCompleteDialog();
  }

  void showWorkoutCompleteDialog() {
    DatabaseHelper().logActivity(workoutName, elapsedTime, '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Workout Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Great job! You’ve finished your $workoutName session.'),
              SizedBox(height: 10),
              Text(
                'Total Duration: ${elapsedTime ~/ 60}:${(elapsedTime % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    workoutTimer.cancel();
    audioPlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutName),
      ),
      body: Column(
        children: [
          // Full-width image for the current exercise
          Card(
            elevation: 5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage(
                    isWorkPhase
                        ? exercises[currentExerciseIndex]['image'] ??
                            defaultImage
                        : restImage, // Show rest image during rest
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Set $currentSet of $sets',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    isWorkPhase ? 'Work' : 'Rest',
                    style: TextStyle(
                      fontSize: 20,
                      color: isWorkPhase ? Colors.green : Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    exercises[currentExerciseIndex]['name'],
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${timerSeconds ~/ 60}:${(timerSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: togglePause,
                        child: Text(isPaused ? 'Resume' : 'Pause'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: endWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('End Workout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
