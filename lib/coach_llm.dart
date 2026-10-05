import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CoachLlmException implements Exception {
  final String message;
  CoachLlmException(this.message);

  @override
  String toString() => message;
}

/// Grok chat for Talk to coach. The key lives in app preferences, never in source.
class CoachLlm {
  static const keyPref = 'healthyme_xai_api_key';
  static const _model = 'grok-4.5';
  static const _url = 'https://api.x.ai/v1/chat/completions';

  static const systemPrompt = '''
You are the Healthy Me coach, a calm impulse-control companion with a physician, yoga, and practical habit tone. The person may be about to scroll, snack, or spiral. Help them interrupt that with one small next step.

Rules:
- Reply in 2 to 4 short sentences. One concrete action. No lecture.
- Prefer one of these: one minute of comfortable nose breathing with no breath hold; a slow body scan from the jaw down; a two-minute walk before acting; naming the snack reason (hunger, boredom, stress, habit, social, or other) then a one-minute pause; a dim, quiet wind-down; or one journal sentence.
- Eating when hungry is valid. Do not shame food.
- Do not claim that breathing, fasting, or a Control Pause measurement proves better health.
- Do not diagnose, prescribe, or override a clinician. If they mention insulin or low blood sugar risk, tell them not to fast and to follow their clinician.
- Do not award points or chase a score.
- If they describe immediate danger or intent to harm themselves or someone else, stop the exercise. Tell them to contact local emergency services or a trusted person. In Colombia call 106. In the US call or text 988.
- You are not therapy and not medical care.
''';

  Future<String?> readKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(keyPref)?.trim();
    if (key == null || key.isEmpty) return null;
    return key;
  }

  Future<void> saveKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(keyPref);
      return;
    }
    await prefs.setString(keyPref, trimmed);
  }

  Future<String> reply({
    required String apiKey,
    required List<Map<String, String>> messages,
  }) async {
    final http.Response res;
    try {
      res = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 320,
              'temperature': 0.4,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                ...messages,
              ],
            }),
          )
          .timeout(const Duration(seconds: 40));
    } on TimeoutException {
      throw CoachLlmException('The coach took too long. Try again.');
    } catch (_) {
      throw CoachLlmException(
        'Could not reach the coach. On a website the browser may block this call. The on-device coach still works.',
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw CoachLlmException(
        'The coach could not reply (${res.statusCode}). Check the key.',
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw CoachLlmException('The coach returned an unexpected reply.');
    }
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw CoachLlmException('The coach returned an empty reply.');
    }
    final message = (choices.first as Map)['message'];
    final content = message is Map ? message['content'] : null;
    if (content is! String || content.trim().isEmpty) {
      throw CoachLlmException('The coach returned an empty reply.');
    }
    return content.trim();
  }
}
