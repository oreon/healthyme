import 'package:flutter/material.dart';
import 'audio_recorder.dart';
import 'config.dart';

class AudioRecorderScreen extends StatefulWidget {
  final Config config;

  AudioRecorderScreen({super.key, required this.config});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder(config: widget.config);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _isRecording
                ? null
                : () async {
                    setState(() => _isRecording = true);
                    await _audioRecorder.startRecording();
                    setState(() => _isRecording = false);
                  },
            child: Text("Start Recording"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isRecording
                ? () async {
                    await _audioRecorder.stopRecording();
                    setState(() => _isRecording = false);
                  }
                : null,
            child: Text("Stop Recording"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _audioRecorder.playRecording(),
            child: Text("Play Recording"),
          ),
        ],
      ),
    );
  }
}
