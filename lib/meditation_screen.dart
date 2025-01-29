import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';
import 'database_helper.dart';
import 'main.dart'; // Import the DatabaseHelper class

abstract class MeditationScreen extends StatefulWidget {
  final String? audioFile; // Audio file for the meditation (optional)
  final String meditationName; // Name of the meditation
  final String
      description; //='Relax your body as much as possible'; // Description of the meditation

  const MeditationScreen({
    super.key,
    this.audioFile,
    required this.meditationName,
    required this.description,
  });
}

abstract class MeditationScreenState<T extends MeditationScreen>
    extends State<T> with WidgetsBindingObserver {
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<int> durations = [1, 5, 10, 15, 30, 45]; // Durations in minutes
  int? selectedDuration; // Selected duration in minutes
  int timerSeconds = 0; // Timer in seconds
  bool isPlaying = false;
  bool isPaused = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Add observer for lifecycle events
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    audioPlayer.dispose(); // Release resources
    timer.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      // App is back in the foreground
      if (isPlaying && timerSeconds <= 0) {
        // If meditation ended while the app was in the background
        playEndAudio();
      }
    }
  }

  void playStartAudio() async {
    await audioPlayer.play(AssetSource('sounds/start.mp3'));
  }

  void playEndAudio() async {
    await audioPlayer.play(AssetSource('sounds/rest.mp3'));
  }

  Future<void> startMeditation() async {
    if (selectedDuration == null) return; // No duration selected

    if (widget.audioFile != null) {
      await audioPlayer.play(
          AssetSource(widget.audioFile!)); // Play the audio file if available
    }

    setState(() {
      isPlaying = true;
      isPaused = false;
      timerSeconds = selectedDuration! * 60; // Convert minutes to seconds
    });

    // Start the timer
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          timer.cancel(); // Stop the timer when it reaches 0
          endMeditation();
        }
      });
    });

    // Start a background task
    Workmanager().registerOneOffTask(
      "meditationTask",
      "meditationTask",
      inputData: <String, dynamic>{
        "duration": selectedDuration! * 60,
      },
    );
  }

  Future<void> pauseMeditation() async {
    if (widget.audioFile != null) {
      await audioPlayer.pause(); // Pause the audio if available
    }
    setState(() {
      isPaused = true;
    });
  }

  Future<void> resumeMeditation() async {
    if (widget.audioFile != null) {
      await audioPlayer.resume(); // Resume the audio if available
    }
    setState(() {
      isPaused = false;
    });
  }

  Future<void> endMeditation() async {
    playEndAudio(); // Play the end audio
    if (widget.audioFile != null) {
      await audioPlayer.stop(); // Stop the audio if available
    }

    timer.cancel(); // Cancel the timer
    setState(() {
      isPlaying = false;
      isPaused = false;
    });

    // Log the meditation session
    await _logMeditation();
  }

  Future<void> _logMeditation() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.logActivity(
        widget.meditationName, (selectedDuration! * 60) - timerSeconds, '');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meditationName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isPlaying)
              Column(
                children: [
                  Text(
                    widget.description, // Render the description
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Select Duration (minutes):',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: durations.map((duration) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDuration = duration;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedDuration == duration ? Colors.blue : null,
                        ),
                        child: Text('$duration'),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        selectedDuration != null ? startMeditation : null,
                    child: Text('Start Meditation'),
                  ),
                ],
              ),
            if (isPlaying)
              Column(
                children: [
                  Text(
                    'Time Remaining: ${timerSeconds ~/ 60}:${(timerSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  if (!isPaused)
                    ElevatedButton(
                      onPressed: pauseMeditation,
                      child: Text('Pause Meditation'),
                    ),
                  if (isPaused)
                    ElevatedButton(
                      onPressed: resumeMeditation,
                      child: Text('Resume Meditation'),
                    ),
                  ElevatedButton(
                    onPressed: endMeditation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('End Meditation'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
