import 'workout_screen.dart';

class YogaScreen extends WorkoutScreen {
  const YogaScreen({super.key});

  @override
  _YogaScreenState createState() => _YogaScreenState();
}

class _YogaScreenState extends WorkoutScreenState<YogaScreen> {
  _YogaScreenState()
      : super(
          exercises: [
            {
              'name': 'Downward Dog',
              'duration': 100,
              'image': 'assets/images/yoga/downward-facingdog.png',
              'description':
                  'Stretches your hamstrings and calves. Deepen with pulling you head towards your knees ',
            },
            {
              'name': 'Plank',
              'duration': 100,
              'image': 'assets/images/yoga/plankpose.png'
            },
            {
              'name': 'Seated Forward Bend',
              'duration': 120,
              'image': 'assets/images/yoga/seatedforward.jpg'
            },
            {
              'name': 'Cobblers Pose',
              'duration': 120,
              'image': 'assets/images/yoga/boundangle.jpg'
            },
            {
              'name': 'Seated Twist Right',
              'duration': 60,
              'image': 'assets/images/yoga/twist.jpg'
            },
            {
              'name': 'Seated Twist Left',
              'duration': 60,
              'image': 'assets/images/yoga/twist.jpg'
            },
            {
              'name': 'Bridge Pose',
              'duration': 120,
              'image': 'assets/images/yoga/bridgepose.png'
            },
            {
              'name': 'Shoulder stand',
              'duration': 180,
              'image': 'assets/images/yoga/shoulderstand.png'
            },
            {
              'name': 'Shavasana (corpse)',
              'duration': 180,
              'image': 'assets/images/yoga/corpse-pose.jpg',
              'description':
                  'Relax your whole body part by part, lay completely still',
              'audio': 'sounds/pre-meals.mp3',
            },
          ],
          sets: 1,
          workoutName: 'Yoga',
          restDuration: 3,
          defaultAudio: 'sounds/yoga.mp3',
        );
}
