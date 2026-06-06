import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      print("DEBUG: TtsService initialized");
    } catch (e) {
      print("ERROR: TtsService init failed: $e");
    }
  }

  Future<void> speak(String text, {bool isTamil = false}) async {
    try {
      final language = isTamil ? "ta-IN" : "en-US";
      
      print("DEBUG: TTS speaking - Language: $language, Text: $text");
      
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      final result = await _tts.speak(text);
      print("DEBUG: TTS speak() completed with result: $result");
    } catch (e) {
      print("ERROR: TTS speak failed: $e");
      rethrow;
    }
  }
}