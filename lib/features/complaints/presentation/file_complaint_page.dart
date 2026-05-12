import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../assistant/data/samadhan_assistant_service.dart';
import '../../assistant/data/voice_input_service.dart';
import '../data/complaint_repository.dart';

class FileComplaintPage extends StatefulWidget {
  const FileComplaintPage({
    super.key,
    ComplaintRepository? repository,
    VoiceInputService? voiceInputService,
    SamadhanAssistantService? assistantService,
  })  : _repository = repository,
        _voiceInputService = voiceInputService,
        _assistantService = assistantService;

  final ComplaintRepository? _repository;
  final VoiceInputService? _voiceInputService;
  final SamadhanAssistantService? _assistantService;

  @override
  State<FileComplaintPage> createState() => _FileComplaintPageState();
}

class _FileComplaintPageState extends State<FileComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final ComplaintRepository _repository;
  late final VoiceInputService _voiceInputService;
  late final SamadhanAssistantService _assistantService;

  bool _saving = false;
  bool _voiceEnabled = false;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? ComplaintRepository();
    _voiceInputService = widget._voiceInputService ?? VoiceInputService();
    _assistantService = widget._assistantService ?? SamadhanAssistantService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _voiceInputService.stopListening();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      // Fallback if location fails
    }

    await _repository.addComplaint(
      citizenName: _nameController.text.trim(),
      citizenContact: _contactController.text.trim(),
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  Future<void> _captureVoice(TextEditingController controller) async {
    if (!_voiceEnabled) {
      _showInfo('Enable voice input first.');
      return;
    }

    try {
      await _voiceInputService.startListening(
        onText: (text) {
          if (!mounted) return;
          setState(() {
            controller.text = text;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          });
        },
      );
    } catch (error) {
      _showInfo(error.toString());
    }
  }

  void _fillDraftSuggestion() {
    final suggestion = _assistantService.suggestComplaintDraft(
      _descriptionController.text,
    );
    _showInfo(suggestion);
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Complaint in Samadhan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: SwitchListTile(
                  title: const Text('Voice input'),
                  subtitle: const Text('Turn on to speak your complaint details.'),
                  value: _voiceEnabled,
                  onChanged: (value) {
                    setState(() {
                      _voiceEnabled = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Citizen name',
                  suffixIcon: IconButton(
                    onPressed: () => _captureVoice(_nameController),
                    icon: Icon(
                      _voiceInputService.isListening ? Icons.mic : Icons.mic_none,
                    ),
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter citizen name' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  suffixIcon: IconButton(
                    onPressed: () => _captureVoice(_contactController),
                    icon: Icon(
                      _voiceInputService.isListening ? Icons.mic : Icons.mic_none,
                    ),
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter contact' : null,
              ),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  suffixIcon: IconButton(
                    onPressed: () => _captureVoice(_subjectController),
                    icon: Icon(
                      _voiceInputService.isListening ? Icons.mic : Icons.mic_none,
                    ),
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter subject' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  suffixIcon: IconButton(
                    onPressed: () => _captureVoice(_descriptionController),
                    icon: Icon(
                      _voiceInputService.isListening ? Icons.mic : Icons.mic_none,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.trim().length < 10
                    ? 'Description should be at least 10 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _fillDraftSuggestion,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Get AI drafting tip'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: Text(_saving ? 'Saving...' : 'Save Offline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
