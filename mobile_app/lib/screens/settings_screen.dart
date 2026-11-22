import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Settings', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            value: s.language,
            decoration: const InputDecoration(labelText: 'Voice language'),
            items: const [
              DropdownMenuItem(value: 'en-US', child: Text('English')),
              DropdownMenuItem(value: 'ar-EG', child: Text('Arabic')),
            ],
            onChanged: (v) => s.update(language: v),
          ),
        ),
      ),
      _slider(context, 'Voice speed', s.speechRate, 0.6, 1.4, (v) => s.update(speechRate: v)),
      _slider(context, 'Text size', s.fontSize, 22, 44, (v) => s.update(fontSize: v)),
      _slider(context, 'Confidence threshold: ${s.threshold.toStringAsFixed(2)}', s.threshold, 0.5, 0.95, (v) => s.update(threshold: v)),
      Card(child: SwitchListTile(title: const Text('Dark mode'), value: s.darkMode, onChanged: (v) => s.update(darkMode: v))),
      Card(child: SwitchListTile(title: const Text('Speak results aloud'), value: s.speakResults, onChanged: (v) => s.update(speakResults: v))),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: TextFormField(
            initialValue: s.serverUrl,
            decoration: const InputDecoration(labelText: 'Server address', helperText: 'Example: http://192.168.1.20:5000'),
            keyboardType: TextInputType.url,
            onFieldSubmitted: (v) => s.update(serverUrl: v.trim()),
          ),
        ),
      ),
    ]);
  }

  Widget _slider(BuildContext context, String label, double value, double min, double max, ValueChanged<double> onChanged) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
          ]),
        ),
      );
}
