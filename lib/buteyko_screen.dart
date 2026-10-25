import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'activity_complete_dialog.dart';
import 'buteyko.dart';
import 'completion.dart';
import 'database_helper.dart';
import 'points.dart';
import 'session_draft.dart';

enum _Stage { controlPause, guided, finished }

/// Guided Buteyko session (spec: "Buteyko task").
///
/// Flow: an optional, user-controlled Control Pause measurement
/// (logged when taken), then two rounds of 2 minutes reduced
/// breathing — soft bell every 8 seconds — and 1 minute normal
/// breathing. Comfortable practice only: the CP is stopped at the
/// first desire to breathe and is never a maximum hold.
class ButeykoScreen extends StatefulWidget {
  const ButeykoScreen({super.key});

  @override
  State<ButeykoScreen> createState() => _ButeykoScreenState();
}

class _ButeykoScreenState extends State<ButeykoScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final AudioPlayer _bellPlayer = AudioPlayer();
  final PracticeTimeTracker _tracker = PracticeTimeTracker();

  /// Points-engine session key, minted once when the screen opens.
  late final String _sessionKey =
      'buteyko:${DateTime.now().toIso8601String()}';

  _Stage _stage = _Stage.controlPause;

  // Control Pause stopwatch state.
  Timer? _cpTimer;
  bool _cpRunning = false;
  int _cpSeconds = 0;
  int? _cpMeasured;

  // Guided phase state.
  Timer? _phaseTimer;
  int _phaseIndex = 0;
  int _phaseElapsed = 0;
  bool _paused = false;
  bool _finished = false;

  ButeykoPhase get _phase => buteykoProgram.phases[_phaseIndex];
  int get _phaseRemaining => _phase.durationSeconds - _phaseElapsed;

  @override
  void dispose() {
    _cpTimer?.cancel();
    _phaseTimer?.cancel();
    _bellPlayer.dispose();
    super.dispose();
  }

  // ---- Control Pause -------------------------------------------------

  void _startCp() {
    setState(() {
      _cpRunning = true;
      _cpSeconds = 0;
      _cpMeasured = null;
    });
    _cpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _cpSeconds++);
    });
  }

  Future<void> _stopCp() async {
    _cpTimer?.cancel();
    final measured = _cpSeconds;
    setState(() {
      _cpRunning = false;
      _cpMeasured = measured;
    });
    // The CP measurement is its own stored record, visible in the
    // Log tab, and is also referenced in the session's completion.
    await _db.insertActivityLog(
      activity: 'Buteyko',
      tasktype: 'buteyko_cp',
      duration: measured,
      comments: 'Control Pause: $measured seconds',
    );
  }

  void _beginGuided() {
    setState(() {
      _stage = _Stage.guided;
      _phaseIndex = 0;
      _phaseElapsed = 0;
      _paused = false;
    });
    _phaseTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  // ---- Guided phases ---------------------------------------------------

  void _tick() {
    if (!mounted || _paused || _finished) return;
    _tracker.tick(isWorkPhase: true, isPaused: _paused);
    setState(() => _phaseElapsed++);

    // Soft bell on the 8-second cadence during reduced breathing.
    if (bellOffsetsInPhase(_phase).contains(_phaseElapsed)) {
      _playSoftBell();
    }

    if (_phaseElapsed >= _phase.durationSeconds) {
      if (_phaseIndex + 1 < buteykoProgram.phases.length) {
        setState(() {
          _phaseIndex++;
          _phaseElapsed = 0;
        });
      } else {
        _finish(ranToCompletion: true);
      }
    }
  }

  void _playSoftBell() {
    // A dedicated low-volume player, so the soft cadence bell never
    // disturbs anything else and never overlaps itself loudly.
    _bellPlayer.setVolume(0.25);
    _bellPlayer.play(AssetSource('sounds/tibet_bell.wav'));
  }

  void _togglePause() => setState(() => _paused = !_paused);

  Future<void> _finish({required bool ranToCompletion}) async {
    if (_finished) return;
    _finished = true;
    _phaseTimer?.cancel();
    _cpTimer?.cancel();
    if (mounted) setState(() => _stage = _Stage.finished);

    final activeSeconds = _tracker.activeSeconds;
    final earned = sessionPoints(activeSeconds);
    if (activeSeconds > 0) {
      await _db.awardSessionPoints(_sessionKey, earned);
    }
    if (!mounted) return;

    final cp = _cpMeasured;
    WorkoutCompleteDialog(
      context: context,
      workoutName: cp != null ? 'Buteyko (CP ${cp}s)' : 'Buteyko',
      elapsedTime: activeSeconds,
      pointsEarned: earned,
      encouragement: meditationEncouragement,
      completionKind: ranToCompletion ? 'full' : 'ended_early',
    ).show();
  }

  // ---- UI ---------------------------------------------------------------

  String _format(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buteyko Breathing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: switch (_stage) {
          _Stage.controlPause => _buildControlPause(),
          _Stage.guided => _buildGuided(),
          _Stage.finished => const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text('Session ended.',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
        },
      ),
    );
  }

  Widget _buildControlPause() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 1 (optional): Control Pause',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Breathe normally through your nose. After a gentle '
          'exhale, hold your breath and start the timer. Stop the '
          'timer at the first clear desire to breathe — this is '
          'not a maximum hold. Stay comfortable.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            _cpMeasured != null
                ? 'Control Pause: ${_cpMeasured}s'
                : _format(_cpSeconds),
            style: const TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        if (_cpRunning)
          ElevatedButton(
            onPressed: _stopCp,
            child: const Text('Stop — record my Control Pause'),
          )
        else ...[
          ElevatedButton(
            onPressed: _startCp,
            child: Text(_cpMeasured != null
                ? 'Measure again'
                : 'Start Control Pause timer'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _beginGuided,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text(_cpMeasured != null
                ? 'Begin breathing'
                : 'Skip CP and begin breathing'),
          ),
        ],
      ],
    );
  }

  Widget _buildGuided() {
    final phase = _phase;
    final isReduced = phase.isReduced;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Round ${phase.round} of ${buteykoProgram.rounds}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isReduced ? 'Reduced breathing' : 'Normal breathing',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          isReduced
              ? 'Breathe less: smaller, quieter breaths through the '
                  'nose. Stay relaxed and comfortable — a gentle '
                  'feeling of air hunger is enough.'
              : 'Let the breath be completely natural. No control, '
                  'no effort — just breathe and rest.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            _format(_phaseRemaining),
            style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
        if (_cpMeasured != null) ...[
          const SizedBox(height: 8),
          Text(
            'Control Pause today: ${_cpMeasured}s',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _togglePause,
          child: Text(_paused ? 'Resume' : 'Pause'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _finish(ranToCompletion: false),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('End session'),
        ),
      ],
    );
  }
}
