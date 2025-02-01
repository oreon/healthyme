import 'package:flutter/material.dart';
import 'package:healthyme/box_breathing_screen.dart';
import 'med_screens.dart';

class MeditationTab extends StatelessWidget {
  const MeditationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meditation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two buttons per row
          crossAxisSpacing: 16.0, // Spacing between columns
          mainAxisSpacing: 16.0, // Spacing between rows
          children: [
            _buildMeditationButton(
              context,
              'Walking Meditation',
              Colors.blue,
              const WalkingMeditationScreen(),
            ),
            _buildMeditationButton(
              context,
              'Body Scan',
              Colors.green,
              const BodyScanScreen(),
            ),
            _buildMeditationButton(
              context,
              'Breath Meditation',
              Colors.orange,
              const BreathMeditationScreen(),
            ),
            _buildMeditationButton(
              context,
              'Eating Meditation',
              Colors.purple,
              const EatingMeditationScreen(),
            ),
            _buildMeditationButton(
              context,
              'Loving Kindness',
              Colors.blue,
              const LovingKindnessScreen(),
            ),
            _buildMeditationButton(
              context,
              'Box Breathing',
              Colors.redAccent,
              BoxBreathingScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationButton(
    BuildContext context,
    String title,
    Color color,
    Widget screen,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
