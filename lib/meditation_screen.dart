import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Add this package
import 'dart:async';
import 'activity_complete_dialog.dart';

import 'main.dart'; // Import the DatabaseHelper class

abstract class MeditationScreen extends StatefulWidget {
  final String? audioFile; // Audio file for the meditation (optional)
  final String meditationName; // Name of the meditation
  final String description; // Description of the meditation

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
  String motivation =
      'Even a short meditation can make you feel relaxed and calm so keep doing meditation snacking and one or two longer sits !
      + ' It is shown to strength your gray matter and prevent cognitive decline as we age';

  // Local notifications setup
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    WidgetsBinding.instance
        .addObserver(this); // Add observer for lifecycle events
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    _initializeNotifications();
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
    if (state == AppLifecycleState.paused) {
      // App is minimized
      if (isPlaying) {
        // Schedule a background task to handle the timer
        Workmanager().registerOneOffTask(
          "meditationTask",
          "meditationTask",
          inputData: <String, dynamic>{
            "duration": timerSeconds,
          },
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      // App is back in the foreground
      Workmanager().cancelByTag("meditationTask"); // Cancel the background task
    }
  }

  void _initializeNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'meditation_channel',
      'Meditation Timer',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
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

    // Show a notification when the meditation ends
    _showNotification(
        'Meditation Complete', 'Your meditation session has ended.');

    WorkoutCompleteDialog(
      context: context,
      workoutName: widget.meditationName, // Your workout name variable
      elapsedTime:
          (selectedDuration! * 60) - timerSeconds, // Your elapsed time variable
    ).show();

    // Log the meditation session
    //await _logMeditation();
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
