/// A persisted checkpoint of an in-progress guided session.
///
/// Drafts let an unfinished session offer **Resume** when the same
/// session is opened again the same day: the saved place (exercise /
/// set), the accumulated active seconds and — crucially — the original
/// session key are restored, so the points engine credits the session
/// once under one key and can never double-count it.
class SessionDraft {
  /// Session family: 'workout' (strength / yoga / pranayama / …) or
  /// 'meditation'.
  final String kind;

  /// Identity within the family: the workout or meditation name.
  final String identity;

  /// The points-engine session key minted when the session first
  /// started; a resumed session reuses it.
  final String sessionKey;

  /// Current exercise index (workout family; 0 for meditation).
  final int exerciseIndex;

  /// Current set, 1-based (workout family; 1 for meditation).
  final int set;

  /// Actively practiced seconds so far (pauses, rests and skipped
  /// segments excluded).
  final int activeSeconds;

  /// Chosen duration for meditation sessions; null for workouts.
  final int? selectedDurationMinutes;

  /// Exercises skipped so far, as 'exerciseIndex:set' keys.
  final List<String> skipped;

  /// Local date (yyyy-mm-dd) the draft was saved; drafts are only
  /// resumable on that same day.
  final String date;

  /// Save time, milliseconds since epoch.
  final int savedAtMillis;

  const SessionDraft({
    required this.kind,
    required this.identity,
    required this.sessionKey,
    this.exerciseIndex = 0,
    this.set = 1,
    required this.activeSeconds,
    this.selectedDurationMinutes,
    this.skipped = const [],
    required this.date,
    required this.savedAtMillis,
  });

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'identity': identity,
        'session_key': sessionKey,
        'exercise_index': exerciseIndex,
        'set': set,
        'active_seconds': activeSeconds,
        'selected_duration_minutes': selectedDurationMinutes,
        'skipped': skipped,
        'date': date,
        'saved_at': savedAtMillis,
      };

  factory SessionDraft.fromJson(Map<String, dynamic> json) => SessionDraft(
        kind: json['kind'] as String? ?? '',
        identity: json['identity'] as String? ?? '',
        sessionKey: json['session_key'] as String? ?? '',
        exerciseIndex: (json['exercise_index'] as num?)?.toInt() ?? 0,
        set: (json['set'] as num?)?.toInt() ?? 1,
        activeSeconds: (json['active_seconds'] as num?)?.toInt() ?? 0,
        selectedDurationMinutes:
            (json['selected_duration_minutes'] as num?)?.toInt(),
        skipped: (json['skipped'] as List?)
                ?.map((value) => value.toString())
                .toList() ??
            const [],
        date: json['date'] as String? ?? '',
        savedAtMillis: (json['saved_at'] as num?)?.toInt() ?? 0,
      );
}

/// Accumulates the actively practiced seconds of a workout session.
///
/// Only unpaused work-phase ticks count: rest-phase seconds and paused
/// wall-clock time never advance [activeSeconds], and a skipped
/// exercise contributes nothing beyond the seconds already practiced
/// before the skip — its remaining seconds are never credited and it is
/// not marked as practiced.
class PracticeTimeTracker {
  int activeSeconds = 0;
  final Set<String> _skipped = {};

  bool get hasSkips => _skipped.isNotEmpty;

  /// Skipped exercises as 'exerciseIndex:set' keys (for draft saving).
  Set<String> get skippedKeys => Set.unmodifiable(_skipped);

  void restoreSkipped(Iterable<String> keys) => _skipped.addAll(keys);

  void reset() {
    activeSeconds = 0;
    _skipped.clear();
  }

  /// Advances the practiced total by one second when appropriate.
  void tick({required bool isWorkPhase, required bool isPaused}) {
    if (!isPaused && isWorkPhase) {
      activeSeconds++;
    }
  }

  /// Marks an exercise as skipped: it is not practiced, and none of
  /// its remaining seconds will ever be credited.
  void skipExercise(int exerciseIndex, int set) {
    _skipped.add('$exerciseIndex:$set');
  }

  bool isPracticed(int exerciseIndex, int set) =>
      !_skipped.contains('$exerciseIndex:$set');
}
