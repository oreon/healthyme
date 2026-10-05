import 'dart:async';
import 'package:flutter/material.dart';
import 'med_screens.dart';

class HelpMeScreen extends StatelessWidget {
  const HelpMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Me')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('What would help right now?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _choice(context, Icons.favorite_outline, 'Strong emotion',
              'Panic, anger, worry, grief, or remorse',
              'Name the feeling. Notice your feet. Relax your shoulders. '
              'Take a gentle pause before deciding what to do next.',
              const GentlePauseScreen(), 'One-minute pause',
              const BodyScanScreen(), 'Body scan'),
          _choice(context, Icons.nights_stay_outlined, 'Help me sleep',
              'Settle down with a body scan',
              'Dim the screen and get comfortable. Let your breathing happen '
              'naturally, then follow the body scan.',
              const BodyScanScreen(), 'Start body scan', null, null),
          _choice(context, Icons.center_focus_strong, 'Help me focus',
              'Calm down and choose one task',
              'Release tension in your shoulders. Pause for a minute, then '
              'choose one task to begin for five minutes.',
              const GentlePauseScreen(), 'One-minute pause',
              const BreathMeditationScreen(), 'Breath meditation'),
          _choice(context, Icons.pause_circle_outline, 'Pause an impulse',
              'Before a snack or distracting app',
              'Notice what you want to do and why. Pause, then choose '
              'intentionally: continue, change course, or wait.',
              const GentlePauseScreen(), 'One-minute pause', null, null),
        ],
      ),
    );
  }

  Widget _choice(BuildContext context, IconData icon, String title,
      String subtitle, String guidance, Widget action, String actionLabel,
      Widget? alternative, String? alternativeLabel) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => _HelpPlan(
              title: title,
              guidance: guidance,
              action: action,
              actionLabel: actionLabel,
              alternative: alternative,
              alternativeLabel: alternativeLabel,
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpPlan extends StatelessWidget {
  final String title;
  final String guidance;
  final Widget action;
  final String actionLabel;
  final Widget? alternative;
  final String? alternativeLabel;

  const _HelpPlan({
    required this.title,
    required this.guidance,
    required this.action,
    required this.actionLabel,
    this.alternative,
    this.alternativeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(guidance,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center),
            if (actionLabel == 'One-minute pause') ...[
              const SizedBox(height: 16),
              const Text('60 seconds', textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute<void>(builder: (_) => action)),
              child: Text(actionLabel),
            ),
            if (alternative != null && alternativeLabel != null)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => alternative!),
                ),
                child: Text(alternativeLabel!),
              ),
          ],
        ),
      ),
    );
  }
}

class GentlePauseScreen extends StatefulWidget {
  const GentlePauseScreen({super.key});

  @override
  State<GentlePauseScreen> createState() => _GentlePauseScreenState();
}

class _GentlePauseScreenState extends State<GentlePauseScreen> {
  Timer? _timer;
  int _remaining = 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gentle pause')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_remaining == 0 ? 'Pause complete' : 'Breathe comfortably',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              const Text('Relax your jaw and shoulders. No need to hold '
                  'your breath or force the pace.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Text(_remaining == 0 ? 'Done' : '$_remaining seconds',
                  style: Theme.of(context).textTheme.headlineMedium),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_remaining == 0 ? 'Return to plan' : 'Stop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
