import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/translation_controller.dart';
import '../widgets/app_theme.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TranslationController>();
    final fontSize = context.select<SettingsController, double>((s) => s.fontSize);
    final preview = c.camera.ready
        ? AspectRatio(aspectRatio: 4 / 3, child: ClipRRect(borderRadius: BorderRadius.circular(18), child: CameraPreview(c.camera.controller!)))
        : AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF17212F), borderRadius: BorderRadius.circular(18)),
              child: const Center(child: Icon(Icons.videocam_off, color: Colors.white38, size: 48)),
            ),
          );

    return ListView(padding: const EdgeInsets.all(16), children: [
      preview,
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_statusText(c), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Semantics(
              liveRegion: true,
              child: Text(c.state == TranslationState.notRecognized ? 'Not recognized' : (c.word ?? '—'),
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: AppColors.navy)),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: c.confidence,
                    color: c.state == TranslationState.notRecognized ? AppColors.bad : AppColors.ok,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${(c.confidence * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            TextButton.icon(onPressed: c.word == null ? null : c.speakAgain, icon: const Icon(Icons.volume_up), label: const Text('Speak again')),
          ]),
        ),
      ),
      const SizedBox(height: 4),
      FilledButton(
        style: c.running ? FilledButton.styleFrom(backgroundColor: AppColors.bad) : null,
        onPressed: c.state == TranslationState.initializing ? null : (c.running ? c.stop : c.start),
        child: Text(c.running ? 'Stop camera' : 'Start camera'),
      ),
    ]);
  }

  String _statusText(TranslationController c) {
    switch (c.state) {
      case TranslationState.idle:
        return 'Camera is off';
      case TranslationState.initializing:
        return 'Starting camera…';
      case TranslationState.tracking:
        return 'Tracking hands';
      case TranslationState.predicting:
        return 'Analyzing…';
      case TranslationState.result:
        return 'Recognized';
      case TranslationState.notRecognized:
        return 'Try the sign again';
      case TranslationState.error:
        return c.errorMessage ?? 'Something went wrong';
    }
  }
}
