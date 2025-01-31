import 'dart:convert';
import 'package:flutter/services.dart';

class Config {
  int recordingIntervalSeconds;
  int recordingDurationSeconds;
  int totalRecordingDurationMinutes;

  Config({
    required this.recordingIntervalSeconds,
    required this.recordingDurationSeconds,
    required this.totalRecordingDurationMinutes,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      recordingIntervalSeconds: json['recording_interval_seconds'],
      recordingDurationSeconds: json['recording_duration_seconds'],
      totalRecordingDurationMinutes: json['total_recording_duration_minutes'],
    );
  }

  static Future<Config> load() async {
    final String configString =
        await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> configJson = jsonDecode(configString);
    return Config.fromJson(configJson);
  }
}
