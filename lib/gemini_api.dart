import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiAPI {
  final String apiKey;
  final String baseUrl =
      'https://api.generativeai.google.com/v1beta2'; // Correct Base URL

  GeminiAPI({required this.apiKey});

  Future<String?> generateText(String prompt) async {
    final url = Uri.parse(
        '$baseUrl/models/gemini-pro:generateText'); // Correct endpoint
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "prompt": {
        "text": prompt,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        //Handle potential variations in response structure.
        if (jsonData['candidates'] != null &&
            jsonData['candidates'] is List &&
            jsonData['candidates'].isNotEmpty) {
          return jsonData['candidates'][0]['output'];
        } else if (jsonData['promptFeedback'] != null &&
            jsonData['promptFeedback']['blockReason'] != null) {
          //Example of handling errors
          return "Error: ${jsonData['promptFeedback']['blockReason']}";
        } else {
          return "Unexpected response format: $jsonData"; //Handle unexpected structures
        }
      } else {
        return 'Error: ${response.statusCode} - ${response.body}'; // Include error details
      }
    } catch (e) {
      return 'Error: $e'; // Catch and return exceptions
    }
  }

  // Example for chat completion (adapt as needed for specific Gemini API calls)
  Future<String?> generateChatCompletion(
      List<Map<String, String>> messages) async {
    final url = Uri.parse(
        '$baseUrl/models/gemini-pro:generateChatCompletion'); // Correct endpoint
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "messages": messages, // Pass the messages list
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['candidates'] != null &&
            jsonData['candidates'] is List &&
            jsonData['candidates'].isNotEmpty) {
          return jsonData['candidates'][0]
              ['content']; // Extract the text content
        } else {
          return "Unexpected response format: $jsonData";
        }
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
