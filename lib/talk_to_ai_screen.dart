import 'package:flutter/material.dart';
import 'help_me_screen.dart';

/// Safe fallback until on-device coaching is available.
class TalkToAIScreen extends StatelessWidget {
  const TalkToAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coaching')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.psychology_outlined, size: 56),
              const SizedBox(height: 20),
              const Text('AI coaching is unavailable in this preview.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('You can still use the guided, offline actions in Help Me.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const HelpMeScreen()),
                ),
                child: const Text('Open Help Me'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
