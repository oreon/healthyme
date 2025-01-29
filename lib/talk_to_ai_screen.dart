// TODO Implement this library.

import 'package:flutter/material.dart';

class TalkToAIScreen extends StatefulWidget {
  const TalkToAIScreen({super.key});

  @override
  _TalkToAIScreenState createState() => _TalkToAIScreenState();
}

class _TalkToAIScreenState extends State<TalkToAIScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _aiResponse = '';

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Simulate an API call to DeepSeek AI
    setState(() {
      _aiResponse = 'Thinking...';
    });

    // Replace this with an actual API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _aiResponse = _getMotivationalResponse(message);
    });
  }

  String _getMotivationalResponse(String message) {
    // Simulate AI response
    if (message.toLowerCase().contains("don't feel like exercising")) {
      return "You got this! Even a small workout is better than none. Start with 5 minutes!";
    }
    return "Stay positive and keep pushing forward!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk to AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Type your message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send'),
            ),
            SizedBox(height: 20),
            Text(
              _aiResponse,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
