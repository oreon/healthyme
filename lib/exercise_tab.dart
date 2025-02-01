import 'kickboxing_screen.dart';
import 'lowerbody_strength.dart';
import 'pranayama_screen.dart';
import 'yoga_screen.dart';
import 'package:flutter/material.dart';

class ExerciseTab extends StatelessWidget {
  const ExerciseTab({super.key});

  void _launch(BuildContext context, screen) {
    // Code to launch kickboxing routine
    // For example:
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _launch(context, LowerBodyWorkoutScreen()),
              child: Text('Lower body strength'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launch(context, UpperBodyWorkoutScreen()),
              child: Text('Upper Body Strength'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launch(context, YogaScreen()),
              child: Text('Yoga'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launch(context, PranayamaScreen()),
              child: Text('Pranayama'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launch(context, KickboxingScreen()),
              child: Text('Kickboxing'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launch(context, KeegalScreen()),
              child: Text('Keegal'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launch(context, FacerciseScreen()),
              child: Text('Facial Exercises'),
            ),
          ],
        ),
      ),
    );
  }
}
