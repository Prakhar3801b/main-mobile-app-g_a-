import 'package:flutter/material.dart';

import '../data/samadhan_assistant_service.dart';
import '../data/voice_input_service.dart';
import '../domain/assistant_message.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({
    super.key,
    SamadhanAssistantService? assistantService,
    VoiceInputService? voiceInputService,
  })  : _assistantService = assistantService,
        _voiceInputService = voiceInputService;

  final SamadhanAssistantService? _assistantService;
  final VoiceInputService? _voiceInputService;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  late final SamadhanAssistantService _assistantService;
  late final VoiceInputService _voiceInputService;
  final TextEditingController _queryController = TextEditingController();
  final List<AssistantMessage> _messages = [];
  bool _voiceEnabled = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _assistantService = widget._assistantService ?? SamadhanAssistantService();
    _voiceInputService = widget._voiceInputService ?? VoiceInputService();
    _messages.add(
      AssistantMessage(
        text: _assistantService.respond(''),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _voiceInputService.stopListening();
    super.dispose();
  }

  Future<void> _askAssistant() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      return;
    }

    setState(() {
      _processing = true;
      _messages.add(
        AssistantMessage(text: query, isUser: true, timestamp: DateTime.now()),
      );
    });

    final reply = _assistantService.respond(query);

    setState(() {
      _messages.add(
        AssistantMessage(text: reply, isUser: false, timestamp: DateTime.now()),
      );
      _processing = false;
    });

    _queryController.clear();
  }

  Future<void> _startVoiceQuery() async {
    if (!_voiceEnabled) {
      _showInfo('Enable voice input first.');
      return;
    }

    try {
      await _voiceInputService.startListening(
        onText: (text) {
          if (!mounted) return;
          setState(() {
            _queryController.text = text;
            _queryController.selection = TextSelection.fromPosition(
              TextPosition(offset: _queryController.text.length),
            );
          });
        },
      );
    } catch (error) {
      _showInfo(error.toString());
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Samadhan AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Voice input'),
                subtitle: const Text('Turn on to speak your questions to the assistant.'),
                value: _voiceEnabled,
                onChanged: (value) {
                  setState(() {
                    _voiceEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('How do I file a complaint?'),
                  onPressed: () {
                    _queryController.text = 'How do I file a complaint?';
                    _askAssistant();
                  },
                ),
                ActionChip(
                  label: const Text('Explain pending and synced'),
                  onPressed: () {
                    _queryController.text = 'Explain pending and synced status';
                    _askAssistant();
                  },
                ),
                ActionChip(
                  label: const Text('How does voice input work?'),
                  onPressed: () {
                    _queryController.text = 'How does voice input work?';
                    _askAssistant();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment:
                        message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 360),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(message.text),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _queryController,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Ask Samadhan AI',
                hintText: 'Example: How should I write an electricity complaint?',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _startVoiceQuery,
                      icon: Icon(
                        _voiceInputService.isListening ? Icons.mic : Icons.mic_none,
                      ),
                    ),
                    IconButton(
                      onPressed: _processing ? null : _askAssistant,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _askAssistant(),
            ),
          ],
        ),
      ),
    );
  }
}
