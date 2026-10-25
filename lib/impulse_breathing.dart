/// Pure model of the impulse box-breathing preset (spec: "Impulse
/// controls and strong emotions").
///
/// **Before eating** and **Before scrolling** open the box-breathing
/// screen directly in this preset: one minute, 4×4 (inhale 4, hold 4,
/// exhale 4, hold 4), with spoken counts and the motivational
/// reminder — no settings or questions first.
library;

/// The motivational reminder shown on the impulse screen, in the
/// spirit of the requested reminder about protecting life goals from
/// shallow pleasures.
const String impulseReminder =
    'One minute of breath now protects the life you are building '
    'from a moment of shallow pleasure.';

/// Fixed configuration of a one-minute impulse breathing pause.
class ImpulseBreathingPreset {
  /// Where the pause was launched from: 'before_eating',
  /// 'before_scrolling', 'strong_emotion', …
  final String source;

  /// Total length of the pause in seconds.
  final int totalSeconds;

  /// Seconds per phase, in order: inhale, hold, exhale, hold.
  final List<int> phaseSeconds;

  /// Spoken/displayed name of each phase, in order.
  final List<String> phaseNames;

  /// The motivational reminder shown prominently on the screen.
  final String reminder;

  const ImpulseBreathingPreset({
    required this.source,
    required this.totalSeconds,
    required this.phaseSeconds,
    required this.phaseNames,
    required this.reminder,
  });
}

/// The impulse preset for a launch [source]: always one minute of
/// 4×4 box breathing.
ImpulseBreathingPreset impulsePresetFor(String source) =>
    ImpulseBreathingPreset(
      source: source,
      totalSeconds: 60,
      phaseSeconds: const [4, 4, 4, 4],
      phaseNames: const ['In', 'Hold', 'Out', 'Hold'],
      reminder: impulseReminder,
    );

const List<String> _spokenCounts = ['two', 'three', 'four'];

/// The calm spoken cue for a moment within the impulse preset: the
/// phase name as the phase begins ("In…", "Hold…", "Out…"), then the
/// counts "two… three… four" on the following seconds. Returns null
/// when nothing should be spoken that second.
String? spokenCueFor({
  required ImpulseBreathingPreset preset,
  required int phaseIndex,
  required int secondInPhase,
}) {
  if (phaseIndex < 0 || phaseIndex >= preset.phaseNames.length) return null;
  if (secondInPhase == 0) return preset.phaseNames[phaseIndex];
  final countIndex = secondInPhase - 1;
  if (countIndex >= 0 && countIndex < _spokenCounts.length) {
    return _spokenCounts[countIndex];
  }
  return null;
}
