import '/meditation_screen.dart';
import 'package:flutter/material.dart';

class BreathMeditationScreen extends MeditationScreen {
  const BreathMeditationScreen({super.key})
      : super(
          description: 'Relax your body and focus on your breath',
          audioFile: 'sounds/3_min_breath.mp3',
          meditationName: 'Breath Meditation',
        );

  @override
  State<BreathMeditationScreen> createState() => _BreathMeditationScreenState();
}

class _BreathMeditationScreenState
    extends MeditationScreenState<BreathMeditationScreen> {
  // Add any specific state logic for Breath Meditation here
}

class BodyScanScreen extends MeditationScreen {
  const BodyScanScreen({super.key})
      : super(
          description: 'Relax your body and focus on your breath',
          audioFile: 'sounds/relax.mp3',
          meditationName: 'Body Scan',
        );

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends MeditationScreenState<BodyScanScreen> {
  // Add any specific state logic for Body Scan here
}

class EatingMeditationScreen extends MeditationScreen {
  const EatingMeditationScreen({super.key})
      : super(
          description: 'Relax your body and focus on your breath',
          audioFile: 'sounds/pre-meals.mp3',
          meditationName: 'Eating Meditation',
        );

  @override
  State<EatingMeditationScreen> createState() => _EatingMeditationScreenState();
}

class _EatingMeditationScreenState
    extends MeditationScreenState<EatingMeditationScreen> {
  // Add any specific state logic for Eating Meditation here
}

class WalkingMeditationScreen extends MeditationScreen {
  const WalkingMeditationScreen({super.key})
      : super(
          description: 'Relax your body and focus on your steps',
          //audioFile: 'sounds/relax.mp3',
          meditationName: 'Walking Meditation',
        );

  @override
  State<WalkingMeditationScreen> createState() =>
      _WalkingMeditationScreenState();
}

class _WalkingMeditationScreenState
    extends MeditationScreenState<WalkingMeditationScreen> {
  // Add any specific state logic for Walking Meditation here
}

class LovingKindnessScreen extends MeditationScreen {
  const LovingKindnessScreen({super.key})
      : super(
          description:
              'Relax your body, put on a budha smile and mentally say may I be happy, may all beings be happy',
          //audioFile: 'sounds/relax.mp3',
          meditationName: 'Walking Meditation',
        );

  @override
  State<LovingKindnessScreen> createState() => _LovingKindnessScreenState();
}

class _LovingKindnessScreenState
    extends MeditationScreenState<LovingKindnessScreen> {
  // Add any specific state logic for Walking Meditation here
}
