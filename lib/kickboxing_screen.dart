import 'workout_screen.dart';

class KickboxingScreen extends WorkoutScreen {
  const KickboxingScreen({super.key});

  @override
  _KickboxingScreenState createState() => _KickboxingScreenState();
}

class _KickboxingScreenState extends WorkoutScreenState<KickboxingScreen> {
  _KickboxingScreenState()
      : super(
          exercises: [
            {
              'name': 'Jab, Cross, Lead Hook',
              'duration': 120,
              'image': 'assets/images/upper/plank.png'
            },
            {
              'name': 'Front Kick, Side Kick, Elbow',
              'duration': 120,
              'image': 'assets/images/upper/superman.webp'
            },
            {
              'name': 'Jab, Cross, Low Kick',
              'duration': 180,
              'image': 'assets/images/upper/plank.png'
            },
            {
              'name': 'Front, Side, Back Kick',
              'duration': 180,
              'image': 'assets/images/upper/VUp.gif'
            },
          ],
          sets: 1,
          restDuration: 60,
          workoutName: 'Kickboxing',
        );
}
