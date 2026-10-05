/// Cloud Gemini calls were removed. Coaching goes through MicroLlm.
class GeminiAPI {
  GeminiAPI({required String apiKey});

  Future<String?> generateText(String prompt) async {
    return 'Cloud AI is disabled. Use the on-device coach.';
  }
}
