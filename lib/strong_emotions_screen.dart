import 'package:flutter/material.dart';

import 'box_breathing_screen.dart';
import 'emotions_data.dart';

/// The "Help Me Now" destination (spec: "Impulse controls and
/// strong emotions"): name what you are feeling, sit with a piece of
/// traditional wisdom for it, and breathe for one minute.
///
/// Verbatim quotations and paraphrases are labeled as such —
/// paraphrases are never dressed up as scripture — and the
/// editorial text is shown under a visible "Reflection" label.
class StrongEmotionsScreen extends StatelessWidget {
  const StrongEmotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strong Emotions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'What are you feeling right now?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the closest match for a moment of wisdom and a '
            'minute of breath.',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemCount: emotionCategories.length,
            itemBuilder: (context, index) {
              final category = emotionCategories[index];
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EmotionDetailScreen(category: category),
                    ),
                  );
                },
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One emotion: a Gurbani entry, a Buddhist entry, our reflection,
/// and a one-minute breathing launch.
class EmotionDetailScreen extends StatelessWidget {
  final EmotionCategory category;

  const EmotionDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _wisdomCard(category.gurbani),
          const SizedBox(height: 16),
          _wisdomCard(category.buddhist),
          const SizedBox(height: 16),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reflection',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(category.reflection,
                      style: const TextStyle(fontSize: 16, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BoxBreathingScreen.impulse(
                      source: 'strong_emotion'),
                ),
              );
            },
            icon: const Icon(Icons.air),
            label: const Text('Breathe for one minute'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wisdomCard(WisdomQuote quote) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quote.tradition,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    quoteKindLabel(quote),
                    style: const TextStyle(fontSize: 11),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quote.text,
              style: const TextStyle(
                  fontSize: 17, fontStyle: FontStyle.italic, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              quote.attribution,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
