import '/workout_screen.dart';

class LowerBodyWorkoutScreen extends WorkoutScreen {
  const LowerBodyWorkoutScreen({super.key});

  @override
  _LowerBodyWorkoutScreenState createState() => _LowerBodyWorkoutScreenState();
}

class _LowerBodyWorkoutScreenState
    extends WorkoutScreenState<LowerBodyWorkoutScreen> {
  _LowerBodyWorkoutScreenState()
      : super(
          exercises: [
            {
              'name': 'Squats',
              'duration': 45,
              'image': 'assets/images/lower/squat.gif'
            },
            {
              'name': 'Right Lunge',
              'duration': 45,
              'image': 'assets/images/lower/lunge.gif'
            },
            {
              'name': 'Left Lunge',
              'duration': 45,
              'image': 'assets/images/lower/lunge.gif'
            },
            {
              'name': 'Side Lunges Right',
              'duration': 45,
              'image': 'assets/images/lower/side_lunge.gif'
            },
            {
              'name': 'Side Lunges Left',
              'duration': 45,
              'image': 'assets/images/lower/side_lunge.gif'
            },
            {
              'name': 'Glute Bridge',
              'duration': 45,
              'image': 'assets/images/lower/glute_bridge.gif'
            },
          ],
          sets: 3,
          workoutName: 'Lower Body Workout',
          restDuration: 15, // 15 seconds of rest for Lower Body Workout
        );
}
