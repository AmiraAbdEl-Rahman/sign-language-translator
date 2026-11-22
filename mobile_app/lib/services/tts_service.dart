import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> configure({required String language, required double rate}) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate * 0.5); // flutter_tts: 0.5 is normal speed
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
