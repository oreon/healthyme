import '/meditation_screen.dart';
import 'package:flutter/material.dart';

class BreathMeditationScreen extends MeditationScreen {
  const BreathMeditationScreen({super.key})
      : super(
          description:
              'Relax your body and focus on your breath at the nostrils',
          audioFile: 'sounds/guide_breath.mp3',
          meditationName: 'Breath Meditation',
          motivation:
              "Breath meditation is shown to increase your attention span, just keep coming back to breath with a smie when the mind wonders",
        );

  @override
  State<BreathMeditationScreen> createState() => _BreathMeditationScreenState();
}

class _BreathMeditationScreenState
    extends MeditationScreenState<BreathMeditationScreen> {}

class BodyScanScreen extends MeditationScreen {
  const BodyScanScreen({super.key})
      : super(
          description: 'Relax your body and focus on your breath',
          audioFile: 'sounds/guide_bodyscan.mp3',
          meditationName: 'Body Scan',
        );

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends MeditationScreenState<BodyScanScreen> {}

class EatingMeditationScreen extends MeditationScreen {
  const EatingMeditationScreen({super.key})
      : super(
          description: 'Relax your body and focus on your breath',
          audioFile: 'sounds/guide_eating.mp3',
          meditationName: 'Eating Meditation',
        );

  @override
  State<EatingMeditationScreen> createState() => _EatingMeditationScreenState();
}

class _EatingMeditationScreenState
    extends MeditationScreenState<EatingMeditationScreen> {}

class WalkingMeditationScreen extends MeditationScreen {
  const WalkingMeditationScreen({super.key})
      : super(
          description: 'Relax your body and focus on your steps',
          audioFile: 'sounds/guide_walking.mp3',
          meditationName: 'Walking Meditation',
        );

  @override
  State<WalkingMeditationScreen> createState() =>
      _WalkingMeditationScreenState();
}

class _WalkingMeditationScreenState
    extends MeditationScreenState<WalkingMeditationScreen> {}

class LovingKindnessScreen extends MeditationScreen {
  const LovingKindnessScreen({super.key})
      : super(
          description:
              'Relax your body, put on a budha smile and mentally say may I be happy, may all beings be happy',
          audioFile: 'sounds/guide_loving.mp3',
          meditationName: 'Loving kindness Meditation',
        );

  @override
  State<LovingKindnessScreen> createState() => _LovingKindnessScreenState();
}

class _LovingKindnessScreenState
    extends MeditationScreenState<LovingKindnessScreen> {}
