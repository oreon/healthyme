import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'coach_llm.dart';
import 'micro_llm.dart';

class _Turn {
  final String role;
  final String text;
  const _Turn(this.role, this.text);

  Map<String, String> toJson() => {'role': role, 'text': text};
}

class TalkToAIScreen extends StatefulWidget {
  const TalkToAIScreen({super.key});

  @override
  State<TalkToAIScreen> createState() => _TalkToAIScreenState();
}

class _TalkToAIScreenState extends State<TalkToAIScreen> {
  static const _threadKey = 'healthyme_coach_thread_v1';
  static const _starters = [
    'I want a snack and I am not sure I am hungry.',
    'I cannot stop scrolling.',
    'Help me sleep.',
    'I feel anxious and want to act on it.',
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final MicroLlm _local = MicroLlm();
  final CoachLlm _llm = CoachLlm();
  final List<_Turn> _messages = [];

  String? _apiKey;
  bool _busy = false;
  bool _lastWasLocal = false;
  String _lastText = '';
  String _lastAction = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final key = await _llm.readKey();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_threadKey);
    final loaded = <_Turn>[];
    if (raw != null) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map && item['role'] is String && item['text'] is String) {
            loaded.add(_Turn(item['role'] as String, item['text'] as String));
          }
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _apiKey = key;
      _messages
        ..clear()
        ..addAll(loaded);
    });
    _jump();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final kept = _messages.length > 40
        ? _messages.sublist(_messages.length - 40)
        : _messages;
    await prefs.setString(
      _threadKey,
      jsonEncode(kept.map((turn) => turn.toJson()).toList()),
    );
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  String? _crisis(String text) {
    final lower = text.toLowerCase();
    const flags = [
      'suicide',
      'kill myself',
      'hurt myself',
      'harm myself',
      'end my life',
      'want to die',
      'self-harm',
      'self harm',
      'kill someone',
      'hurt someone',
    ];
    if (flags.any(lower.contains)) {
      return 'This is not a routine exercise. If you are in immediate danger, contact local emergency services or a person you trust. In Colombia you can call 106. In the US, call or text 988.';
    }
    return null;
  }

  Future<void> _send([String? preset]) async {
    final message = (preset ?? _messageController.text).trim();
    if (message.isEmpty || _busy) return;
    _messageController.clear();
    setState(() {
      _busy = true;
      _error = '';
      _lastWasLocal = false;
      _lastAction = '';
      _messages.add(_Turn('user', message));
    });
    _jump();

    final crisis = _crisis(message);
    if (crisis != null) {
      setState(() {
        _busy = false;
        _messages.add(_Turn('coach', crisis));
      });
      await _persist();
      _jump();
      return;
    }

    final key = _apiKey;
    if (key != null && key.isNotEmpty) {
      final history = _messages
          .where((turn) => turn.role == 'user' || turn.role == 'coach')
          .map(
            (turn) => {
              'role': turn.role == 'coach' ? 'assistant' : 'user',
              'content': turn.text,
            },
          )
          .toList();
      final recent = history.length > 12
          ? history.sublist(history.length - 12)
          : history;
      try {
        final reply = await _llm.reply(apiKey: key, messages: recent);
        if (!mounted) return;
        setState(() {
          _busy = false;
          _messages.add(_Turn('coach', reply));
        });
        await _persist();
        _jump();
        return;
      } on CoachLlmException catch (error) {
        if (!mounted) return;
        setState(() => _error = error.message);
      }
    }

    final local = await _local.reply(message);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastWasLocal = true;
      _lastText = message;
      _lastAction = local.action;
      final note = key == null
          ? '\n\nOn-device coach. Add a Grok key to talk with the model.'
          : '\n\nFell back to the on-device coach.';
      _messages.add(_Turn('coach', '${local.text}$note'));
    });
    await _persist();
    _jump();
  }

  Future<void> _learn(bool helped) async {
    if (_lastText.isEmpty || _lastAction.isEmpty) return;
    await _local.learn(text: _lastText, action: _lastAction, helped: helped);
    if (!mounted) return;
    setState(() {
      _messages.add(
        _Turn(
          'coach',
          helped
              ? 'Saved on this device. A similar note will lean this way next time.'
              : 'Saved on this device. A similar note will try another action next time.',
        ),
      );
      _lastAction = '';
    });
    await _persist();
    _jump();
  }

  Future<void> _editKey() async {
    final controller = TextEditingController(text: _apiKey ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Grok key'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'xAI API key, stored only on this device',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (saved == null) return;
    await _llm.saveKey(saved);
    final key = await _llm.readKey();
    if (!mounted) return;
    setState(() => _apiKey = key);
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk to coach'),
        actions: [
          IconButton(
            tooltip: 'Grok key',
            onPressed: _editKey,
            icon: const Icon(Icons.key),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              hasKey
                  ? 'Grok answers this chat. The key stays on this device.'
                  : 'On-device coach until you add a Grok key.',
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.isEmpty ? 1 : _messages.length,
              itemBuilder: (context, index) {
                if (_messages.isEmpty) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final starter in _starters)
                        ActionChip(
                          label: Text(starter),
                          onPressed: _busy ? null : () => _send(starter),
                        ),
                    ],
                  );
                }
                final turn = _messages[index];
                final mine = turn.role == 'user';
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: mine ? Colors.blue : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(turn.text),
                  ),
                );
              },
            ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error),
            ),
          if (_lastWasLocal && _lastAction.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
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
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'What is going on?',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  onPressed: _busy ? null : () => _send(),
                  icon: Icon(_busy ? Icons.hourglass_top : Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
