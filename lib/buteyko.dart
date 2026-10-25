/// Pure model of the guided Buteyko session (spec: "Buteyko task").
///
/// A session is: an OPTIONAL, user-controlled Control Pause (CP)
/// step, then two rounds of two minutes of reduced breathing (soft
/// bell every eight seconds) followed by one minute of normal
/// breathing. The timed breathing totals six minutes, plus the CP
/// step. The CP is a measurement the user starts and stops; it is
/// never a maximal hold and it is not part of the guided phases.
library;

/// One timed phase of the guided breathing sequence.
class ButeykoPhase {
  /// 'reduced' (breathe smaller and quieter) or 'normal'.
  final String kind;

  /// 1-based round this phase belongs to.
  final int round;

  /// Length of the phase in seconds.
  final int durationSeconds;

  /// Seconds between soft bells during this phase, or null for no
  /// bells (the normal-breathing minute is silent).
  final int? bellIntervalSeconds;

  const ButeykoPhase({
    required this.kind,
    required this.round,
    required this.durationSeconds,
    this.bellIntervalSeconds,
  });

  bool get isReduced => kind == 'reduced';
}

/// The full Buteyko program structure.
class ButeykoProgram {
  /// The Control Pause is always offered and always skippable.
  final bool controlPauseOptional;

  /// The guided phases after the CP step, in order.
  final List<ButeykoPhase> phases;

  const ButeykoProgram({
    required this.controlPauseOptional,
    required this.phases,
  });

  /// Total guided breathing seconds (CP measurement excluded).
  int get totalGuidedSeconds =>
      phases.fold(0, (sum, phase) => sum + phase.durationSeconds);

  int get rounds =>
      phases.fold(0, (max, phase) => phase.round > max ? phase.round : max);
}

/// The session as specified: CP (optional) → [reduced 120 s with an
/// 8-second bell cadence, normal 60 s] × 2 rounds.
const ButeykoProgram buteykoProgram = ButeykoProgram(
  controlPauseOptional: true,
  phases: [
    ButeykoPhase(
        kind: 'reduced', round: 1, durationSeconds: 120, bellIntervalSeconds: 8),
    ButeykoPhase(kind: 'normal', round: 1, durationSeconds: 60),
    ButeykoPhase(
        kind: 'reduced', round: 2, durationSeconds: 120, bellIntervalSeconds: 8),
    ButeykoPhase(kind: 'normal', round: 2, durationSeconds: 60),
  ],
);

/// Elapsed-second offsets within [phase] at which the soft bell
/// rings: every [ButeykoPhase.bellIntervalSeconds], including the
/// phase's final second (the transition cue). Empty when the phase
/// has no bell cadence.
List<int> bellOffsetsInPhase(ButeykoPhase phase) {
  final interval = phase.bellIntervalSeconds;
  if (interval == null || interval <= 0) return const [];
  return [
    for (var t = interval; t <= phase.durationSeconds; t += interval) t,
  ];
}
