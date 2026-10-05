import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// On-device micro model. No network calls.
/// A hashed bag-of-words scores a few actions. Completions and
/// "this helped" / "not this" updates move the weights.
class MicroLlm {
  static const _storeKey = 'healthyme_micro_llm_v1';
  static const dim = 64;
  static const actions = [
    'breathe',
    'body_scan',
    'walk',
    'snack_pause',
    'sleep',
    'focus',
    'journal',
  ];

  final Map<String, List<double>> _weights = {
    for (final action in actions) action: List<double>.filled(dim, 0),
  };
  final List<Map<String, dynamic>> events = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final weights = decoded['weights'] as Map<String, dynamic>? ?? {};
      for (final action in actions) {
        final row = weights[action];
        if (row is List && row.length == dim) {
          _weights[action] = row.map((v) => (v as num).toDouble()).toList();
        }
      }
      final saved = decoded['events'];
      if (saved is List) {
        events
          ..clear()
          ..addAll(saved.map((e) => Map<String, dynamic>.from(e as Map)));
      }
    }
    _loaded = true;
  }

  Future<CoachReply> reply(String text) async {
    await load();
    final crisis = _crisis(text);
    if (crisis != null) return crisis;

    final features = _features(text);
    final scores = <String, double>{
      for (final action in actions) action: _score(action, features),
    };
    final ranked = actions.toList()
      ..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    final top = ranked.first;
    final second = ranked[1];
    return CoachReply(
      action: top,
      alternate: second,
      text: _script(top, text, scores[top]!),
      scores: scores,
    );
  }

  Future<void> learn({
    required String text,
    required String action,
    required bool helped,
  }) async {
    await load();
    final features = _features(text);
    final step = helped ? 0.15 : -0.12;
    final row = _weights[action];
    if (row == null) return;
    for (final index in features.keys) {
      row[index] += step * features[index]!;
    }
    if (!helped) {
      final other = actions.firstWhere((a) => a != action);
      final alt = _weights[other]!;
      for (final index in features.keys) {
        alt[index] += 0.05 * features[index]!;
      }
    }
    events.add({
      't': DateTime.now().toIso8601String(),
      'text': text,
      'action': action,
      'helped': helped,
    });
    if (events.length > 200) {
      events.removeRange(0, events.length - 200);
    }
    await _save();
  }

  Future<void> recordBehavior(String activity) async {
    await learn(text: activity, action: _actionFor(activity), helped: true);
  }

  String _actionFor(String activity) {
    final lower = activity.toLowerCase();
    if (lower.contains('sleep')) return 'sleep';
    if (lower.contains('walk')) return 'walk';
    if (lower.contains('scan')) return 'body_scan';
    if (lower.contains('breath') || lower.contains('pranayama')) return 'breathe';
    if (lower.contains('snack') || lower.contains('food') || lower.contains('eat')) {
      return 'snack_pause';
    }
    if (lower.contains('journal')) return 'journal';
    return 'focus';
  }

  Map<int, double> _features(String text) {
    final tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toList();
    final hour = DateTime.now().hour;
    final bag = <int, double>{hour % dim: 0.4};
    if (tokens.isEmpty) {
      bag[0] = 1;
      return bag;
    }
    for (final token in tokens) {
      bag[token.hashCode.abs() % dim] = (bag[token.hashCode.abs() % dim] ?? 0) + 1;
    }
    final norm = sqrt(bag.values.fold<double>(0, (s, v) => s + v * v));
    if (norm == 0) return bag;
    return bag.map((k, v) => MapEntry(k, v / norm));
  }

  double _score(String action, Map<int, double> features) {
    final row = _weights[action]!;
    var sum = 0.0;
    features.forEach((index, value) => sum += row[index] * value);
    sum += _prior(action);
    return sum;
  }

  double _prior(String action) {
    final hour = DateTime.now().hour;
    if (action == 'sleep' && (hour >= 21 || hour < 5)) return 0.35;
    if (action == 'snack_pause' && (hour >= 15 && hour <= 21)) return 0.15;
    if (action == 'breathe') return 0.05;
    return 0;
  }

  String _script(String action, String text, double score) {
    final learned = score > 0.2 ? ' This matches what has helped you before.' : '';
    switch (action) {
      case 'breathe':
        return 'Pause for one minute. Breathe in through the nose and out through the nose, no hold.$learned';
      case 'body_scan':
        return 'Start at the head and move down slowly. Soften the jaw and shoulders before the next choice.$learned';
      case 'walk':
        return 'Stand up and walk for two minutes before you act on "$text".$learned';
      case 'snack_pause':
        return 'Name the reason: hunger, boredom, stress, or habit. Then take the one-minute pause. Eating when hungry is fine.$learned';
      case 'sleep':
        return 'Dim the screen. A short body scan or quiet breathing is enough. No score to chase.$learned';
      case 'journal':
        return 'Write one sentence about what you want to do next, then stop.$learned';
      default:
        return 'Pick one small next task. Two slow breaths, then start it.$learned';
    }
  }

  CoachReply? _crisis(String text) {
    final lower = text.toLowerCase();
    const flags = ['suicide', 'kill myself', 'hurt myself', 'end my life'];
    if (flags.any(lower.contains)) {
      return CoachReply(
        action: 'help',
        alternate: 'help',
        text:
            'This is not a routine exercise. If you are in immediate danger, contact local emergency services or a person you trust. In Colombia you can call 106. In the US, call or text 988.',
        scores: const {},
        crisis: true,
      );
    }
    return null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storeKey,
      jsonEncode({'weights': _weights, 'events': events}),
    );
  }
}

class CoachReply {
  final String action;
  final String alternate;
  final String text;
  final Map<String, double> scores;
  final bool crisis;

  const CoachReply({
    required this.action,
    required this.alternate,
    required this.text,
    required this.scores,
    this.crisis = false,
  });
}
