import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config.dart';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  final List<String> _recordedFiles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  int _totalRecordingDuration = 0;

  final Config config;

  AudioRecorder({required this.config});

  Future<void> initRecorder() async {
    await Permission.microphone.request();
    await _recorder!.openRecorder();
  }

  Future<void> startRecording() async {
    if (!_isRecording) {
      _recorder = FlutterSoundRecorder();
      await initRecorder();
      _isRecording = true;

      while (
          _totalRecordingDuration < config.totalRecordingDurationMinutes * 60) {
        // Record for the configured duration
        final String filePath = await _getRecordingFilePath();
        await _recorder!.startRecorder(toFile: filePath);
        await Future.delayed(
            Duration(seconds: config.recordingDurationSeconds));
        await _recorder!.stopRecorder();

        _recordedFiles.add(filePath);
        _totalRecordingDuration += config.recordingDurationSeconds;

        // Wait for the configured interval
        await Future.delayed(
            Duration(seconds: config.recordingIntervalSeconds));
      }

      _isRecording = false;
      await _concatenateRecordings();
    }
  }

  Future<void> _concatenateRecordings() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String outputPath = '${appDir.path}/final_recording.aac';

    // Concatenate all recorded files into one
    // Note: This is a placeholder. You may need to use a library like `ffmpeg` for actual concatenation.
    final File outputFile = File(outputPath);
    for (final filePath in _recordedFiles) {
      final File file = File(filePath);
      await outputFile.writeAsBytes(await file.readAsBytes(),
          mode: FileMode.append);
    }

    print("Final recording saved at: $outputPath");
  }

  Future<void> playRecording() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String outputPath = '${appDir.path}/final_recording.aac';

    await _audioPlayer.setFilePath(outputPath);
    await _audioPlayer.play();
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _recorder!.stopRecorder();
      _isRecording = false;
    }
  }

  Future<void> dispose() async {
    await _recorder!.closeRecorder();
    _recorder = null;
    await _audioPlayer.dispose();
  }

  Future<String> _getRecordingFilePath() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
  }
}
