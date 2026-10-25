// Tests for the completion-moment helpers: feeling faces,
// encouragement lines and the share-text builder.

import 'package:flutter_test/flutter_test.dart';

import 'package:healthyme/completion.dart';

void main() {
  group('feeling faces and encouragement', () {
    test('there are five faces from awful to great', () {
      expect(feelingFaces, hasLength(5));
      expect(feelingFaces.first, '😖');
      expect(feelingFaces.last, '😄');
    });

    test('encouragement follows the activity kind', () {
      expect(encouragementFor(isMeditation: true),
          'Your mind and brain will thank you!');
      expect(encouragementFor(isMeditation: false),
          'Great job for your body!');
    });
  });

  group('buildShareText', () {
    test('includes activity, points, feeling face and reflection', () {
      final text = buildShareText(
        activityName: 'Yoga',
        points: 40,
        feelingFace: '🙂',
        reflection: 'calmer',
      );
      expect(text,
          'Yoga — Well done! 40 points. Feeling: 🙂 calmer. — Calm n Healthy');
    });

    test('includes the reflection without a face', () {
      final text = buildShareText(
        activityName: 'Body Scan',
        points: 30,
        reflection: 'Slept-ready',
      );
      expect(text,
          'Body Scan — Well done! 30 points. Slept-ready. — Calm n Healthy');
    });

    test('omits feeling and reflection when not provided', () {
      final text = buildShareText(activityName: 'Pranayama', points: 24);
      expect(text, 'Pranayama — Well done! 24 points. — Calm n Healthy');
    });

    test('does not double-punctuate a finished reflection', () {
      final text = buildShareText(
        activityName: 'Yoga',
        points: 40,
        feelingFace: '😄',
        reflection: 'Great session!',
      );
      expect(text,
          'Yoga — Well done! 40 points. Feeling: 😄 Great session! — Calm n Healthy');
    });
  });
}
