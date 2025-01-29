import 'workout_screen.dart';
import 'package:flutter/material.dart';

class PranayamaScreen extends WorkoutScreen {
  const PranayamaScreen({super.key});

  @override
  _PranayamaScreenState createState() => _PranayamaScreenState();
}

class _PranayamaScreenState extends WorkoutScreenState<PranayamaScreen> {
  _PranayamaScreenState()
      : super(exercises: [
          {
            'name': 'Bhastrika',
            'duration': 180,
            'image': 'assets/images/meditation_image.jpg'
          },
          {
            'name': 'Kapalbhati',
            'duration': 300,
            'image': 'assets/images/meditation_image.jpg'
          },
          {
            'name': 'Nadi Shodhan',
            'duration': 420,
            'image': 'assets/images/meditation_image.jpg'
          },
          {
            'name': 'Bhramari',
            'duration': 120,
            'image': 'assets/images/bhramarimeditation_image.jpg'
          },
          {
            'name': 'Ujjayi',
            'duration': 180,
            'image': 'assets/images/meditation_image.jpg'
          },
        ], sets: 1, workoutName: 'Pranayama', restDuration: 0);
}
