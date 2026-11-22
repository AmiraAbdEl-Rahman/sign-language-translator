import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../db/history_repository.dart';
import '../models/history_entry.dart';
import '../models/prediction.dart';
import '../services/api_client.dart';
import '../services/camera_service.dart';
import '../services/frame_encoder.dart';
import '../services/tts_service.dart';
import 'settings_controller.dart';

enum TranslationState { idle, initializing, tracking, predicting, result, notRecognized, error }

class TranslationController extends ChangeNotifier {
  static const windowFrames = 20; // about 2 seconds at 10 FPS

  final SettingsController settings;
  final CameraService camera = CameraService();
  final TtsService tts = TtsService();
  final HistoryRepository history = HistoryRepository();
  late ApiClient api = ApiClient(settings.serverUrl);

  TranslationState state = TranslationState.idle;
  String? word;
  double confidence = 0;
  String? errorMessage;

  final List<String> _buffer = [];
  bool _busy = false;
  String? _lastWord;
  DateTime _lastWordAt = DateTime.fromMillisecondsSinceEpoch(0);

  TranslationController(this.settings);

  bool get running => state != TranslationState.idle && state != TranslationState.error;

  Future<void> start() async {
    if (running) return;
    _set(TranslationState.initializing);
    try {
      api = ApiClient(settings.serverUrl);
      await tts.configure(language: settings.language, rate: settings.speechRate);
      await camera.initialize();
      _buffer.clear();
      await camera.startStream(_onFrame, fps: 10);
      _set(TranslationState.tracking);
    } catch (e) {
      errorMessage = e.toString();
      _set(TranslationState.error);
    }
  }

  void _onFrame(CameraImage image) {
    if (_busy || state == TranslationState.predicting) return;
    final jpeg = FrameEncoder.toJpeg(image, rotation: camera.sensorOrientation);
    _buffer.add(base64Encode(jpeg));
    if (_buffer.length >= windowFrames) _predict();
  }

  Future<void> _predict() async {
    _busy = true;
    final frames = List<String>.from(_buffer);
    _buffer.clear();
    _set(TranslationState.predicting);
    try {
      final Prediction p = await api.predictImages(frames);
      confidence = p.confidence;
      if (p.confidence >= settings.threshold && p.label != null) {
        word = p.label;
        _set(TranslationState.result);
        await _handleResult(p.label!, p.confidence);
      } else {
        word = null;
        _set(TranslationState.notRecognized);
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
      _set(TranslationState.error);
      await stop();
    } finally {
      _busy = false;
      if (running && state != TranslationState.error) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (running) _set(TranslationState.tracking);
      }
    }
  }

  Future<void> _handleResult(String label, double conf) async {
    final now = DateTime.now();
    // Do not repeat the same word within 2 seconds.
    if (label == _lastWord && now.difference(_lastWordAt) < const Duration(seconds: 2)) return;
    _lastWord = label;
    _lastWordAt = now;
    await history.add(HistoryEntry(label: label, confidence: conf, createdAt: now));
    if (settings.speakResults) await tts.speak(label);
  }

  Future<void> speakAgain() async {
    if (word != null) await tts.speak(word!);
  }

  Future<void> stop() async {
    await camera.dispose();
    _buffer.clear();
    if (state != TranslationState.error) _set(TranslationState.idle);
  }

  void _set(TranslationState s) {
    state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    camera.dispose();
    tts.stop();
    super.dispose();
  }
}
