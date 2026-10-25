// Shared constants and pure helpers for the session-completion
// moment: feeling faces, encouragement lines and the share text.

/// The five feeling faces, from awful to great.
const List<String> feelingFaces = ['😖', '🙁', '😐', '🙂', '😄'];

/// Encouragement shown when a meditation session completes.
const String meditationEncouragement = 'Your mind and brain will thank you!';

/// Encouragement shown when a physical activity completes.
const String physicalEncouragement = 'Great job for your body!';

/// The encouragement line for a completed session by kind.
String encouragementFor({required bool isMeditation}) =>
    isMeditation ? meditationEncouragement : physicalEncouragement;

/// Builds the text shared from the completion dialog: the activity,
/// its earned points, and — when the user picked them — the feeling
/// face and written reflection. Nothing else is ever included.
String buildShareText({
  required String activityName,
  required int points,
  String? feelingFace,
  String? reflection,
}) {
  final buffer = StringBuffer('$activityName — Well done! $points points.');
  final note = reflection?.trim() ?? '';
  final hasFace = feelingFace != null && feelingFace.isNotEmpty;
  if (hasFace) {
    buffer.write(' Feeling: $feelingFace');
    if (note.isNotEmpty) {
      buffer.write(' ${_withSentenceEnd(note)}');
    }
  } else if (note.isNotEmpty) {
    buffer.write(' ${_withSentenceEnd(note)}');
  }
  buffer.write(' — Calm n Healthy');
  return buffer.toString();
}

String _withSentenceEnd(String text) =>
    text.endsWith('.') || text.endsWith('!') || text.endsWith('?')
        ? text
        : '$text.';
