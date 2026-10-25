import 'activity_complete_dialog.dart';
import 'completion.dart';
import 'database_helper.dart';
import 'points.dart';
import 'session_draft.dart';
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
  final String? defaultAudio; // Default audio for the entire session
  final String? motivationString; // Purpose

  /// Counter noun for the current item: 'Exercise' generally, 'Pose'
  /// for yoga.
  final String progressUnit;

  int currentExerciseIndex = 0;
  int currentSet = 1;
  int timerSeconds = 0;
  bool isWorkPhase = true;
  bool isPaused = false;
  Timer? timer;
  bool isWorkoutStarted = false; // Track if the workout has started
  final AudioPlayer audioPlayer = AudioPlayer();
  final String restImage = 'assets/images/rest.jpg';

  int totalDuration = 0;

  /// Practiced-time accounting: only unpaused work-phase seconds are
  /// accumulated; rest seconds and skipped remainders never count.
  final PracticeTimeTracker practice = PracticeTimeTracker();

  /// Total actively practiced seconds so far in this session.
  int get elapsedTime => practice.activeSeconds;

  /// Unique key for this session instance, generated when the workout
  /// starts; the points engine credits the session under this key so a
  /// re-save can never double-count it. A resumed session reuses the
  /// key stored in its draft.
  String? _sessionKey;

  /// A same-day in-progress draft restored on open, if any. While one
  /// is present the primary button offers Resume instead of Start.
  SessionDraft? _restoredDraft;

  /// Set once the session has been completed/ended, so leaving the
  /// screen afterwards does not save a fresh draft.
  bool _sessionFinished = false;

  WorkoutScreenState(
      {required this.exercises,
      required this.sets,
      required this.workoutName,
      required this.restDuration,
      this.defaultImage = 'assets/images/default.jpg', // Default stock image
      this.defaultAudio = 'sounds/workout.mp3', // Default
      this.progressUnit = 'Exercise',
      this.motivationString =
          'This will make you feel really good afterwards so just do it'});

  @override
  void initState() {
    super.initState();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    timerSeconds =
        exercises[currentExerciseIndex]['duration'] as int; // Cast to int
    totalDuration = exercises.fold(
            0, (sum, exercise) => sum + (exercise['duration'] as int)) *
        sets; // Cast to int
    _loadDraft();
  }

  /// Restores a same-day unfinished session, if one was checkpointed:
  /// place, set, practiced seconds and the original session key.
  Future<void> _loadDraft() async {
    final draft =
        await DatabaseHelper().getSessionDraft('workout', workoutName);
    if (!mounted || draft == null || isWorkoutStarted) return;
    setState(() {
      _restoredDraft = draft;
      _sessionKey = draft.sessionKey;
      currentExerciseIndex =
          draft.exerciseIndex.clamp(0, exercises.length - 1).toInt();
      currentSet = draft.set.clamp(1, sets).toInt();
      practice.activeSeconds = draft.activeSeconds;
      practice.restoreSkipped(draft.skipped);
      isWorkPhase = true;
      isPaused = false;
      timerSeconds = exercises[currentExerciseIndex]['duration'] as int;
    });
  }

  /// Checkpoints the in-progress session so it can be resumed later
  /// today. Called on pause, on exercise/set transitions and on exit.
  void _saveDraft() {
    final sessionKey = _sessionKey;
    if (sessionKey == null || _sessionFinished) return;
    DatabaseHelper().saveSessionDraft(SessionDraft(
      kind: 'workout',
      identity: workoutName,
      sessionKey: sessionKey,
      exerciseIndex: currentExerciseIndex,
      set: currentSet,
      activeSeconds: practice.activeSeconds,
      skipped: practice.skippedKeys.toList(),
      date: DatabaseHelper().getTodaysDate(),
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  void startWorkout() {
    // A resumed session keeps its stored key (points stay single-count);
    // a fresh session mints a new one.
    _sessionKey ??=
        'workout:$workoutName:${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      isWorkoutStarted = true;
    });
    //startWorkoutTimer();
    startTimer();
    playStartAudio();
    WakelockPlus.enable();
  }

  /// Discards the restored draft and starts the session from the top
  /// with a fresh session key.
  void startFreshWorkout() {
    DatabaseHelper().clearSessionDraft('workout', workoutName);
    setState(() {
      _restoredDraft = null;
      _sessionKey = null;
      currentExerciseIndex = 0;
      currentSet = 1;
      practice.reset();
      isWorkPhase = true;
      isPaused = false;
      timerSeconds = exercises[currentExerciseIndex]['duration'] as int;
    });
    startWorkout();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (tick) {
      if (!mounted) {
        tick.cancel();
        return;
      }
      if (!isPaused) {
        // Only unpaused work-phase ticks are practiced time; rest
        // seconds never advance the practiced total.
        practice.tick(isWorkPhase: isWorkPhase, isPaused: isPaused);
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
              // Switch to the next exercise or set.
              if (!_advanceToNextExercise()) {
                timer?.cancel();
                isWorkoutStarted = false;
                WakelockPlus.disable();
                showWorkoutCompleteDialog(
                    completionKind:
                        practice.hasSkips ? 'with_skips' : 'full');
                return;
              }
            }
            _saveDraft();
          }
        });
      }
    });
  }

  /// Moves to the next exercise or set and starts its work phase.
  /// Returns false when the last exercise of the last set is done.
  bool _advanceToNextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      currentExerciseIndex++;
    } else if (currentSet < sets) {
      currentSet++;
      currentExerciseIndex = 0;
    } else {
      return false;
    }
    isWorkPhase = true;
    timerSeconds = exercises[currentExerciseIndex]['duration'] as int;
    playStartAudio();
    return true;
  }

  /// Skips the current exercise (or the current rest): the session
  /// advances without crediting the skipped exercise's remaining
  /// seconds, and a skipped exercise is not marked as practiced.
  void skipCurrent() {
    if (!isWorkoutStarted) return;
    setState(() {
      if (isWorkPhase) {
        practice.skipExercise(currentExerciseIndex, currentSet);
      }
      if (!_advanceToNextExercise()) {
        timer?.cancel();
        isWorkoutStarted = false;
        WakelockPlus.disable();
        showWorkoutCompleteDialog(
            completionKind: practice.hasSkips ? 'with_skips' : 'full');
        return;
      }
    });
    _saveDraft();
  }

  void playStartAudio() async {
    // Stop default audio if exercise-specific audio is available
    if (exercises[currentExerciseIndex]['audio'] != null) {
      // await backgroundAudioPlayer.stop(); // Stop default audio
      await audioPlayer
          .play(AssetSource(exercises[currentExerciseIndex]['audio']));
    } else if (defaultAudio != null) {
      // Resume default audio if no exercise-specific audio is available
      // if (!(await backgroundAudioPlayer.state == PlayerState.playing)) {
      //   await backgroundAudioPlayer.play(AssetSource(defaultAudio!));
      await audioPlayer.play(AssetSource(defaultAudio!));
    } else {
      await audioPlayer.play(AssetSource('sounds/workout.mp3'));
    }
    //
  }

  void playRestAudio() async {
    await audioPlayer.play(AssetSource('sounds/rest.mp3'));
  }

  /// Rings the completion bell once (the session's own audio has
  /// already been stopped by the caller).
  void _playCompletionBell() {
    final bellPlayer = AudioPlayer();
    bellPlayer.setReleaseMode(ReleaseMode.release);
    bellPlayer.play(AssetSource('sounds/tibet_bell.wav'));
    bellPlayer.onPlayerComplete.first
        .then((_) => bellPlayer.dispose())
        .catchError((_) {});
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
    if (isPaused) {
      _saveDraft();
    } else {
      playStartAudio();
    }
  }

  void endWorkout() {
    timer?.cancel();
    timer = null;

    setState(() {
      isWorkoutStarted = false;
    });

    showWorkoutCompleteDialog(
        completionKind: practice.hasSkips ? 'with_skips' : 'ended_early');
  }

  void showWorkoutCompleteDialog({String completionKind = 'full'}) async {
    _sessionFinished = true;
    await audioPlayer.stop();
    _playCompletionBell();
    await DatabaseHelper().clearSessionDraft('workout', workoutName);
    // Credit the session's points for its active (unpaused, work-phase)
    // elapsed time under its session key.
    final earnedPoints = sessionPoints(elapsedTime);
    final sessionKey = _sessionKey;
    if (sessionKey != null) {
      await DatabaseHelper().awardSessionPoints(sessionKey, earnedPoints);
    }
    if (!mounted) return;
    WorkoutCompleteDialog(
      context: context,
      workoutName: workoutName, // Your workout name variable
      elapsedTime: elapsedTime, // Your elapsed time variable
      pointsEarned: earnedPoints,
      encouragement: physicalEncouragement,
      completionKind: completionKind,
    ).show();
  }

  @override
  void dispose() {
    // Checkpoint an unfinished session so it can be resumed today.
    if (isWorkoutStarted) {
      _saveDraft();
    }
    timer?.cancel();
    timer = null;

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
              height: MediaQuery.of(context).size.height * 0.50,
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
                  if (!isWorkoutStarted)
                    ElevatedButton(
                      onPressed: startWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                      child: Text(
                        _restoredDraft != null ? 'Resume' : 'Start Workout',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  if (!isWorkoutStarted && _restoredDraft != null)
                    TextButton(
                      onPressed: startFreshWorkout,
                      child: Text('Start over'),
                    ),
                  if (!isWorkoutStarted) Text(motivationString!),
                  if (isWorkoutStarted)
                    Text(
                      '$progressUnit ${currentExerciseIndex + 1} of ${exercises.length}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  if (isWorkoutStarted)
                    Text(
                      'Set $currentSet of $sets',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 20),
                  if (isWorkoutStarted)
                    Text(
                      isWorkPhase
                          ? exercises[currentExerciseIndex]['name']
                          : 'Rest',
                      style: TextStyle(
                        fontSize: 20,
                        color: isWorkPhase ? Colors.green : Colors.orange,
                      ),
                    ),
                  SizedBox(height: 20),
                  if (isWorkoutStarted)
                    if (isWorkPhase &&
                        exercises[currentExerciseIndex]['description'] !=
                            null) // Show description if available
                      Text(
                        exercises[currentExerciseIndex]['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                  SizedBox(height: 20),
                  if (isWorkoutStarted)
                    Text(
                      '${timerSeconds ~/ 60}:${(timerSeconds % 60).toString().padLeft(2, '0')}',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 40),
                  if (isWorkoutStarted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: togglePause,
                          child: Text(isPaused ? 'Resume' : 'Pause'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: skipCurrent,
                          child: Text('Skip'),
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
