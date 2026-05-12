import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputService {
  VoiceInputService({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;
  bool _available = false;

  Future<bool> initialize() async {
    _available = await _speechToText.initialize();
    return _available;
  }

  Future<void> startListening({
    required void Function(String text) onText,
    String? localeId,
  }) async {
    if (!_available) {
      final ok = await initialize();
      if (!ok) {
        throw Exception('Voice input is unavailable on this device.');
      }
    }

    await _speechToText.listen(
      localeId: localeId,
      onResult: (SpeechRecognitionResult result) {
        onText(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
