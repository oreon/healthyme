import 'package:flutter/material.dart';

import 'micro_llm.dart';

class TalkToAIScreen extends StatefulWidget {
  const TalkToAIScreen({super.key});

  @override
  State<TalkToAIScreen> createState() => _TalkToAIScreenState();
}

class _TalkToAIScreenState extends State<TalkToAIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MicroLlm _model = MicroLlm();
  String _aiResponse = '';
  String _lastText = '';
  String _lastAction = '';
  bool _busy = false;

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    setState(() => _busy = true);
    final reply = await _model.reply(message);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastText = message;
      _lastAction = reply.action;
      _aiResponse = reply.text;
    });
  }

  Future<void> _learn(bool helped) async {
    if (_lastText.isEmpty || _lastAction.isEmpty) return;
    await _model.learn(text: _lastText, action: _lastAction, helped: helped);
    if (!mounted) return;
    setState(() {
      _aiResponse = helped
          ? 'Saved. Next time a similar note will lean this way.'
          : 'Saved. Next time a similar note will try the other action.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Talk to AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'On this device only. No cloud model. It shifts after you say whether the suggestion helped.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'What is going on?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _busy ? null : _sendMessage,
              child: Text(_busy ? 'Thinking' : 'Ask'),
            ),
            const SizedBox(height: 16),
            Text(_aiResponse),
            if (_lastAction.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _learn(true),
                      child: const Text('This helped'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _learn(false),
                      child: const Text('Not this'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
