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
            // {
            //   'name': 'Plank jacks',
            //   'duration': 45,
            //   'image': 'assets/images/upper/Plank_jacks.gif'
            // },
            {
              'name': 'Plank Ups',
              'duration': 45,
              'image': 'assets/images/upper/Plank_Ups.gif'
            },
            {
              'name': 'Pushups',
              'duration': 45,
              'image': 'assets/images/upper/modified-pushups.gif'
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
              'description':
                  'Get in plank position, put your weight on your forearms and brace your stomach as if someone is about to punch you',
              'image': 'assets/images/upper/plank.webp'
            },
          ],
          sets: 3,
          workoutName: 'Upper Body Workout',
          restDuration: 18, // 15 seconds of rest for Lower Body Workout
        );
}

class KeegalScreen extends WorkoutScreen {
  const KeegalScreen({super.key});

  @override
  _KeegalScreenState createState() => _KeegalScreenState();
}

class _KeegalScreenState extends WorkoutScreenState<KeegalScreen> {
  _KeegalScreenState()
      : super(
          exercises: [
            {
              'name': 'Keegal',
              'duration': 10,
              'description':
                  'Pull your pelvic muscles up and hold as if you were holding your pee',
              'image': 'assets/images/upper/VUp.gif'
            },

            // {
            //   'name': 'Plank jacks',
            //   'duration': 45,
            //   'image': 'assets/images/upper/Plank_jacks.gif'
            // },
          ],
          sets: 10,
          workoutName: 'Keegal',
          restDuration: 5, // 15 seconds of rest for Lower Body Workout
        );
}

class FacerciseScreen extends WorkoutScreen {
  const FacerciseScreen({super.key});

  @override
  _FacerciseScreenState createState() => _FacerciseScreenState();
}

class _FacerciseScreenState extends WorkoutScreenState<FacerciseScreen> {
  _FacerciseScreenState()
      : super(
          exercises: [
            {
              'name': 'Cheek pufs',
              'duration': 45,
              'description':
                  'Puff your right cheek then left cheek - will help remove naso labial folds',
              'image': 'assets/images/upper/VUp.gif'
            },
            {
              'name': 'Eye squints',
              'duration': 45,
              'description':
                  'Puff your right cheek then left cheek - will help remove naso labial folds',
              'image': 'assets/images/upper/VUp.gif'
            },
          ],
          sets: 3,
          workoutName: 'Facial exercises',
          restDuration: 5, // 15 seconds of rest for Lower Body Workout
        );
}
