import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For playing bell sound

class BoxBreathingScreen extends StatefulWidget {
  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _selectedBreathDuration = 4; // Default breath duration in seconds
  int _selectedExerciseDuration = 3; // Default exercise duration in minutes

  final List<int> _breathDurations = [3, 4, 5]; // Breath duration options
  final List<int> _exerciseDurations = [3, 5]; // Exercise duration options

  bool _isExerciseStarted = false;
  int _currentStep = 0; // 0: Inhale, 1: Hold, 2: Exhale, 3: Hold
  int _elapsedTime = 0; // Elapsed time in seconds

  late AudioPlayer _audioPlayer; // For playing bell sound

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize audio player
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _selectedBreathDuration),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStep();
        }
      });
  }

  void _nextStep() async {
    // Play bell sound at each transition
    await _audioPlayer.play(AssetSource(
        'sounds/start.mp3')); // Add a bell sound file to your assets

    setState(() {
      _currentStep = (_currentStep + 1) % 4; // Cycle through steps
      _controller.duration = Duration(seconds: _selectedBreathDuration);
      _controller.forward(from: 0);
    });
  }

  void _startExercise() {
    setState(() {
      _isExerciseStarted = true;
      _elapsedTime = 0;
      _currentStep = 0;
      _controller.duration = Duration(seconds: _selectedBreathDuration);
      _controller.forward(from: 0);
    });

    // Timer to track total exercise duration
    Future.delayed(Duration(seconds: _selectedExerciseDuration * 60), () {
      setState(() {
        _isExerciseStarted = false;
        _controller.stop();
      });
    });

    // Update elapsed time every second
    Future.doWhile(() async {
      if (_isExerciseStarted) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _elapsedTime++;
        });
        return true;
      }
      return false;
    });
  }

  void _stopExercise() {
    setState(() {
      _isExerciseStarted = false;
      _controller.stop();
    });
  }

  String _getStepText() {
    switch (_currentStep) {
      case 0:
        return 'Inhale';
      case 1:
        return 'Hold';
      case 2:
        return 'Exhale';
      case 3:
        return 'Hold';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Box Breathing Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isExerciseStarted) ...[
              Text(
                'Select Breath Duration (seconds):',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _breathDurations.map((duration) {
                  return ChoiceChip(
                    label: Text('$duration sec'),
                    selected: _selectedBreathDuration == duration,
                    onSelected: (selected) {
                      setState(() {
                        _selectedBreathDuration = duration;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Select Exercise Duration (minutes):',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _exerciseDurations.map((duration) {
                  return ChoiceChip(
                    label: Text('$duration min'),
                    selected: _selectedExerciseDuration == duration,
                    onSelected: (selected) {
                      setState(() {
                        _selectedExerciseDuration = duration;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startExercise,
                child: Text(
                  'Start Exercise',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
            if (_isExerciseStarted) ...[
              Text(
                _getStepText(),
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: 10,
              ),
              SizedBox(height: 20),
              Text(
                'Elapsed Time: $_elapsedTime seconds',
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _stopExercise,
                child: Text(
                  'Stop Exercise',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
