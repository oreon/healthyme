import 'kickboxing_screen.dart';
import 'lowerbody_strength.dart';
import 'pranayama_screen.dart';
import 'yoga_screen.dart';
import 'package:flutter/material.dart';

class ExerciseTab extends StatelessWidget {
  const ExerciseTab({super.key});

  void _launchExerciseRoutine(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => LowerBodyWorkoutScreen()));
  }

  void _launchUpper(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UpperBodyWorkoutScreen()));
  }

  void _launchYoga(BuildContext context) {
    // Code to launch yoga routine
    // For example:
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => YogaScreen()));
  }

  void _launchPranayama(BuildContext context) {
    // Code to launch pranayama routine
    // For example:
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PranayamaScreen()));
  }

  void _launchKickboxing(BuildContext context) {
    // Code to launch kickboxing routine
    // For example:
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => KickboxingScreen()));
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
              onPressed: () => _launchExerciseRoutine(context),
              child: Text('Lower body strength'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launchUpper(context),
              child: Text('Upper Body Strength'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launchYoga(context),
              child: Text('Yoga'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launchPranayama(context),
              child: Text('Pranayama'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _launchKickboxing(context),
              child: Text('Kickboxing'),
            ),
          ],
        ),
      ),
    );
  }
}
