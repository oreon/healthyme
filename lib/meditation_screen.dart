import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Add this package
import 'dart:async';
import 'activity_complete_dialog.dart';
import 'completion.dart';
import 'database_helper.dart';
import 'points.dart';
import 'session_draft.dart';

import 'main.dart'; // Import the callback dispatcher class

abstract class MeditationScreen extends StatefulWidget {
  final String? audioFile; // Audio file for the meditation (optional)
  final String meditationName; // Name of the meditation
  final String description; // Description of the meditation
  final String? motivation; // Optional motivation string

  const MeditationScreen({
    super.key,
    this.audioFile,
    required this.meditationName,
    required this.description,
    this.motivation, // Add motivation as an optional parameter
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

  /// Unique key for this session instance, generated when the meditation
  /// starts; the points engine credits the session under this key so a
  /// re-save can never double-count it. A resumed session reuses the
  /// key stored in its draft.
  String? _sessionKey;

  /// A same-day in-progress draft restored on open, if any. While one
  /// is present the primary button offers Resume instead of Start.
  SessionDraft? _restoredDraft;

  bool _timerStarted = false;

  /// Set once the session has ended, so leaving the screen afterwards
  /// does not save a fresh draft.
  bool _sessionFinished = false;

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
    );
    _initializeNotifications();
    _loadDraft();
  }

  @override
  void dispose() {
    // Checkpoint an unfinished session so it can be resumed today.
    if (isPlaying && !_sessionFinished) {
      _saveDraft();
    }
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    audioPlayer.dispose(); // Release resources
    if (_timerStarted) {
      timer.cancel(); // Cancel the timer
    }
    super.dispose();
  }

  /// Restores a same-day unfinished meditation, if one was
  /// checkpointed: its chosen duration, practiced seconds and the
  /// original session key.
  Future<void> _loadDraft() async {
    final draft = await DatabaseHelper()
        .getSessionDraft('meditation', widget.meditationName);
    if (!mounted || draft == null || isPlaying) return;
    setState(() {
      _restoredDraft = draft;
      _sessionKey = draft.sessionKey;
      selectedDuration = draft.selectedDurationMinutes;
    });
  }

  /// Checkpoints the in-progress session so it can be resumed later
  /// today. Called on pause and on exit.
  void _saveDraft() {
    final sessionKey = _sessionKey;
    final duration = selectedDuration;
    if (sessionKey == null || duration == null || _sessionFinished) return;
    DatabaseHelper().saveSessionDraft(SessionDraft(
      kind: 'meditation',
      identity: widget.meditationName,
      sessionKey: sessionKey,
      activeSeconds: (duration * 60) - timerSeconds,
      selectedDurationMinutes: duration,
      date: DatabaseHelper().getTodaysDate(),
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Discards the restored draft so the next start is a fresh session.
  void startFreshMeditation() {
    DatabaseHelper().clearSessionDraft('meditation', widget.meditationName);
    setState(() {
      _restoredDraft = null;
      _sessionKey = null;
      selectedDuration = null;
    });
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

  /// Rings the completion bell once (the session's guided audio is
  /// stopped separately by the caller).
  void _playCompletionBell() {
    final bellPlayer = AudioPlayer();
    bellPlayer.setReleaseMode(ReleaseMode.release);
    bellPlayer.play(AssetSource('sounds/tibet_bell.wav'));
    bellPlayer.onPlayerComplete.first
        .then((_) => bellPlayer.dispose())
        .catchError((_) {});
  }

  Future<void> startMeditation() async {
    if (selectedDuration == null) return; // No duration selected

    if (widget.audioFile != null) {
      await audioPlayer.play(
          AssetSource(widget.audioFile!)); // Play the audio file if available
    }

    // A resumed session keeps its stored key (points stay
    // single-count) and counts down only the unpracticed remainder.
    _sessionKey ??=
        'meditation:${widget.meditationName}:${DateTime.now().microsecondsSinceEpoch}';
    final totalSeconds = selectedDuration! * 60;
    final resumedSeconds = _restoredDraft?.activeSeconds ?? 0;
    setState(() {
      isPlaying = true;
      isPaused = false;
      timerSeconds = resumedSeconds > 0 && resumedSeconds < totalSeconds
          ? totalSeconds - resumedSeconds
          : totalSeconds; // Convert minutes to seconds
    });

    // Start the timer. Ticks are skipped while paused (same pattern as
    // WorkoutScreenState), so paused wall-clock time is never counted
    // as practiced time.
    _timerStarted = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (timerSeconds > 0) {
            timerSeconds--;
          } else {
            timer.cancel(); // Stop the timer when it reaches 0
            endMeditation();
          }
        });
      }
    });
  }

  Future<void> pauseMeditation() async {
    if (widget.audioFile != null) {
      await audioPlayer.pause(); // Pause the audio if available
    }
    setState(() {
      isPaused = true;
    });
    _saveDraft();
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
    // Ring the bell once, whether the session ran to completion or
    // was ended early.
    final ranToCompletion = timerSeconds <= 0;
    _sessionFinished = true;
    _playCompletionBell();
    if (widget.audioFile != null) {
      await audioPlayer.stop(); // Stop the audio if available
    }

    timer.cancel(); // Cancel the timer
    setState(() {
      isPlaying = false;
      isPaused = false;
    });
    await DatabaseHelper()
        .clearSessionDraft('meditation', widget.meditationName);

    // Show a notification when the meditation ends
    _showNotification(
        'Meditation Complete', 'Your meditation session has ended.');

    // Active practiced seconds: the countdown only advances while
    // unpaused, so paused wall-clock time is excluded.
    final activeSeconds = (selectedDuration! * 60) - timerSeconds;
    final earnedPoints = sessionPoints(activeSeconds);
    final sessionKey = _sessionKey;
    if (sessionKey != null) {
      await DatabaseHelper().awardSessionPoints(sessionKey, earnedPoints);
    }
    if (!mounted) return;

    WorkoutCompleteDialog(
      context: context,
      workoutName: widget.meditationName, // Your workout name variable
      elapsedTime: activeSeconds, // Your elapsed time variable
      pointsEarned: earnedPoints,
      encouragement: meditationEncouragement,
      completionKind: ranToCompletion ? 'full' : 'ended_early',
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
                            // Choosing a different duration than the
                            // restored draft's starts a fresh session.
                            if (_restoredDraft != null &&
                                _restoredDraft!.selectedDurationMinutes !=
                                    duration) {
                              _restoredDraft = null;
                              _sessionKey = null;
                            }
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
                    child: Text(_restoredDraft != null
                        ? 'Resume Meditation'
                        : 'Start Meditation'),
                  ),
                  if (_restoredDraft != null)
                    TextButton(
                      onPressed: startFreshMeditation,
                      child: Text('Start over'),
                    ),
                  if (widget.motivation !=
                      null) // Display motivation if provided
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        widget.motivation!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
