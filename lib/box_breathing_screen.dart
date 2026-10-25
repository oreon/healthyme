import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For playing bell sound
import 'package:flutter_tts/flutter_tts.dart';

import 'database_helper.dart';
import 'impulse_breathing.dart';
import 'points.dart';

/// Speaks the impulse breathing cues aloud. Every call is guarded:
/// when text-to-speech is unavailable (tests, desktop, no engine)
/// it fails silently and never blocks the breathing timer.
class _SpeechCues {
  final FlutterTts _tts = FlutterTts();
  bool _failed = false;

  Future<void> speak(String text) async {
    if (_failed) return;
    try {
      await _tts.speak(text);
    } catch (_) {
      _failed = true;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing to stop.
    }
  }
}

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key}) : _impulseSource = null;

  /// Launches the screen directly in the impulse preset (Before
  /// eating / Before scrolling / strong emotions): one minute of
  /// voiced 4×4 box breathing, no settings first. [source] records
  /// where the pause was launched from.
  const BoxBreathingScreen.impulse({super.key, required String source})
      : _impulseSource = source;

  final String? _impulseSource;

  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _selectedBreathDuration = 4; // Default breath duration in seconds
  int _selectedExerciseDuration = 3; // Default exercise duration in minutes

  final List<int> _breathDurations = [3, 4, 5]; // Breath duration options
  final List<int> _exerciseDurations = [3, 5]; // Exercise duration options

  bool _isExerciseStarted = false;
  int _currentStep = 0; // 0: Inhale, 1: Hold, 2: Exhale, 3: Hold
  int _elapsedTime = 0; // Elapsed time in seconds

  late AudioPlayer _audioPlayer; // For playing bell sound

  // Impulse preset state.
  ImpulseBreathingPreset? _preset;
  final _SpeechCues _speech = _SpeechCues();
  Timer? _impulseTimer;
  int _impulseElapsed = 0;
  bool _impulseRunning = false;
  bool _impulseFinished = false;
  late final String _impulseSessionKey;

  bool get _isImpulse => _preset != null;

  int get _impulsePhaseIndex {
    final preset = _preset!;
    final cycleSeconds = preset.phaseSeconds.fold(0, (a, b) => a + b);
    final inCycle = _impulseElapsed % cycleSeconds;
    var acc = 0;
    for (var i = 0; i < preset.phaseSeconds.length; i++) {
      acc += preset.phaseSeconds[i];
      if (inCycle < acc) return i;
    }
    return preset.phaseSeconds.length - 1;
  }

  int get _impulseSecondInPhase {
    final preset = _preset!;
    final cycleSeconds = preset.phaseSeconds.fold(0, (a, b) => a + b);
    var inCycle = _impulseElapsed % cycleSeconds;
    for (final phase in preset.phaseSeconds) {
      if (inCycle < phase) return inCycle;
      inCycle -= phase;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize audio player
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _selectedBreathDuration),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStep();
        }
      });

    if (widget._impulseSource != null) {
      _preset = impulsePresetFor(widget._impulseSource!);
      _impulseSessionKey =
          'impulse:${_preset!.source}:${DateTime.now().toIso8601String()}';
      // Open straight into the pause — no settings, no questions.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _startImpulse());
    }
  }

  // ---- Impulse preset ----------------------------------------------------

  void _startImpulse() {
    if (!mounted || _impulseRunning || _impulseFinished) return;
    setState(() {
      _impulseRunning = true;
      _impulseElapsed = 0;
    });
    _speakCurrentCue();
    _impulseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_impulseRunning) return;
      setState(() => _impulseElapsed++);
      if (_impulseElapsed >= _preset!.totalSeconds) {
        _finishImpulse(completed: true);
      } else {
        _speakCurrentCue();
      }
    });
  }

  void _speakCurrentCue() {
    final cue = spokenCueFor(
      preset: _preset!,
      phaseIndex: _impulsePhaseIndex,
      secondInPhase: _impulseSecondInPhase,
    );
    if (cue != null) {
      // Fire and forget: speech must never block the timer.
      unawaited(_speech.speak(cue));
    }
  }

  Future<void> _finishImpulse({required bool completed}) async {
    if (_impulseFinished) return;
    _impulseFinished = true;
    _impulseTimer?.cancel();
    unawaited(_speech.stop());
    if (mounted) setState(() => _impulseRunning = false);

    final activeSeconds = _impulseElapsed;
    final earned = sessionPoints(activeSeconds);
    final db = DatabaseHelper();
    if (activeSeconds > 0) {
      await db.awardSessionPoints(_impulseSessionKey, earned);
    }
    await db.logCompletion(
      activity: 'Box Breathing',
      duration: activeSeconds,
      comments: 'Impulse pause — source: ${_preset!.source}',
      completionKind: completed ? 'full' : 'ended_early',
      points: earned,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(completed
            ? 'Well done! One calm minute banked.'
            : 'Pause ended early — well done for starting.'),
      ),
    );
    Navigator.of(context).pop();
  }

  void _stopImpulse() => _finishImpulse(completed: false);

  // ---- Classic (settings-first) flow --------------------------------------

  void _nextStep() async {
    // Play bell sound at each transition
    await _audioPlayer.play(AssetSource(
        'sounds/start.mp3')); // Add a bell sound file to your assets

    setState(() {
      _currentStep = (_currentStep + 1) % 4; // Cycle through steps
      _controller.duration = Duration(seconds: _selectedBreathDuration);
      _controller.forward(from: 0);
    });
  }

  void _startExercise() {
    setState(() {
      _isExerciseStarted = true;
      _elapsedTime = 0;
      _currentStep = 0;
      _controller.duration = Duration(seconds: _selectedBreathDuration);
      _controller.forward(from: 0);
    });

    // Timer to track total exercise duration
    Future.delayed(Duration(seconds: _selectedExerciseDuration * 60), () {
      setState(() {
        _isExerciseStarted = false;
        _controller.stop();
      });
    });

    // Update elapsed time every second
    Future.doWhile(() async {
      if (_isExerciseStarted) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _elapsedTime++;
        });
        return true;
      }
      return false;
    });
  }

  void _stopExercise() {
    setState(() {
      _isExerciseStarted = false;
      _controller.stop();
    });
  }

  String _getStepText() {
    switch (_currentStep) {
      case 0:
        return 'Inhale';
      case 1:
        return 'Hold';
      case 2:
        return 'Exhale';
      case 3:
        return 'Hold';
      default:
        return '';
    }
  }

  // Calculate remaining time in minutes and seconds
  String _getRemainingTime() {
    int totalDuration = _selectedExerciseDuration * 60;
    int remainingTime = totalDuration - _elapsedTime;
    int minutes = remainingTime ~/ 60;
    int seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _impulseTimer?.cancel();
    unawaited(_speech.stop());
    _controller.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isImpulse) return _buildImpulse(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Box Breathing Exercise'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isExerciseStarted) ...[
                Text(
                  'Select Breath Duration (seconds):',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _breathDurations.map((duration) {
                    return ChoiceChip(
                      label: Text('$duration sec'),
                      selected: _selectedBreathDuration == duration,
                      onSelected: (selected) {
                        setState(() {
                          _selectedBreathDuration = duration;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text(
                  'Select Exercise Duration (minutes):',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _exerciseDurations.map((duration) {
                    return ChoiceChip(
                      label: Text('$duration min'),
                      selected: _selectedExerciseDuration == duration,
                      onSelected: (selected) {
                        setState(() {
                          _selectedExerciseDuration = duration;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startExercise,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Start Exercise',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
              if (_isExerciseStarted) ...[
                Text(
                  _getStepText(),
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Make the animation square-shaped
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.6, // 60% of screen width
                  height: MediaQuery.of(context).size.width *
                      0.6, // Same as width to make it square
                  child: CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: 10,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Remaining Time: ${_getRemainingTime()}',
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _stopExercise,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Stop Exercise',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpulse(BuildContext context) {
    final preset = _preset!;
    final remaining = preset.totalSeconds - _impulseElapsed;
    final phaseName = preset.phaseNames[_impulsePhaseIndex];
    final count = _impulseSecondInPhase + 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Minute Breathing Pause'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  preset.reminder,
                  style: const TextStyle(
                      fontSize: 17, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              phaseName,
              style: const TextStyle(
                  fontSize: 44, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(fontSize: 28, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: _impulseElapsed / preset.totalSeconds,
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Text(
              'Remaining: 0:${remaining.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _impulseRunning ? _stopImpulse : null,
              style:
                  OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('End pause'),
            ),
          ],
        ),
      ),
    );
  }
}
