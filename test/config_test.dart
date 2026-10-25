import 'package:flutter_test/flutter_test.dart';

import 'package:healthyme/config.dart';

void main() {
  group('Config.fromJson', () {
    test('maps the snake_case JSON fields onto the object', () {
      final config = Config.fromJson(const {
        'recording_interval_seconds': 300,
        'recording_duration_seconds': 30,
        'total_recording_duration_minutes': 480,
      });

      expect(config.recordingIntervalSeconds, 300);
      expect(config.recordingDurationSeconds, 30);
      expect(config.totalRecordingDurationMinutes, 480);
    });

    test('throws when a required field is missing', () {
      expect(
        () => Config.fromJson(const {'recording_interval_seconds': 300}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
