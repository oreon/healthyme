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

class UpperBodyWorkoutScreen extends WorkoutScreen {
  const UpperBodyWorkoutScreen({super.key});

  @override
  _UpperBodyWorkoutScreenState createState() => _UpperBodyWorkoutScreenState();
}

class _UpperBodyWorkoutScreenState
    extends WorkoutScreenState<UpperBodyWorkoutScreen> {
  _UpperBodyWorkoutScreenState()
      : super(
          exercises: [
            {
              'name': 'Leg raises',
              'duration': 45,
              'image': 'assets/images/upper/VUp.gif'
            },
            {
              'name': 'Pushups',
              'duration': 45,
              'image': 'assets/images/upper/modified-pushups.gif'
            },
            {
              'name': 'Plank jacks',
              'duration': 45,
              'image': 'assets/images/upper/Plank_jacks.gif'
            },
            {
              'name': 'Plank_Ups.gif',
              'duration': 45,
              'image': 'assets/images/upper/Plank_ups.gif'
            },
            {
              'name': 'Plank to Dolphin',
              'duration': 45,
              'image': 'assets/images/upper/PlankToDolphinPose.gif'
            },
            {
              'name': 'Superman',
              'duration': 45,
              'image': 'assets/images/upper/superman.webp'
            },
            {
              'name': 'Plank',
              'duration': 50,
              'image': 'assets/images/upper/plank.png'
            },
          ],
          sets: 3,
          workoutName: 'Upper Body Workout',
          restDuration: 18, // 15 seconds of rest for Lower Body Workout
        );
}
