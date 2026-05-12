class SamadhanAssistantService {
  String respond(String query) {
    final normalized = query.toLowerCase().trim();

    if (normalized.isEmpty) {
      return _defaultResponse();
    }

    if (_matchesAny(normalized, ['pending', 'synced', 'registered', 'status'])) {
      return 'Pending complaints are saved on the device. Synced complaints reached the server. '
          'Registered complaints have a confirmed server record and remote ID.';
    }

    if (_matchesAny(normalized, ['file', 'submit', 'complaint', 'register'])) {
      return 'Open File Complaint, enter citizen details, add a clear subject and a specific description, '
          'then save it offline. Use Sync when internet is available.';
    }

    if (_matchesAny(normalized, ['voice', 'microphone', 'speak'])) {
      return 'Turn on voice input with the switch in the complaint screen or assistant screen, then tap the mic '
          'next to the field you want to fill. Speak in short, clear sentences.';
    }

    if (_matchesAny(normalized, ['road', 'water', 'electricity', 'garbage', 'category'])) {
      return 'Describe the issue with location, urgency, and impact. Samadhan will help route complaints for '
          'roads, water, power, sanitation, and general civic issues.';
    }

    if (_matchesAny(normalized, ['sync', 'offline', 'internet', 'network'])) {
      return 'You can work offline with local SQLite storage. When connectivity returns, press Sync so queued '
          'complaints are sent to the backend and registered centrally.';
    }

    return 'I can help you file complaints, explain complaint statuses, guide voice input, and suggest how to '
        'write a complete complaint. Try asking about filing, sync, voice, or statuses.';
  }

  String suggestComplaintDraft(String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      return 'Start with the issue, location, and impact. Example: Streetlight failure near Ward 4 market since last night causing safety concerns.';
    }

    return 'Suggested draft: $trimmed. Add location, how long the problem has existed, and who is affected so the department can act faster.';
  }

  bool _matchesAny(String input, List<String> keywords) {
    return keywords.any(input.contains);
  }

  String _defaultResponse() {
    return 'Welcome to Samadhan. I can help you file a complaint, explain statuses, and guide you through offline sync and voice input.';
  }
}
