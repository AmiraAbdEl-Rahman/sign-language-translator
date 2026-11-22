import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  String language = 'en-US';
  double speechRate = 1.0;
  double fontSize = 32;
  double threshold = 0.8;
  bool darkMode = false;
  bool speakResults = true;
  String serverUrl = 'http://10.0.2.2:5000'; // Android emulator -> host machine

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    language = p.getString('language') ?? language;
    speechRate = p.getDouble('speechRate') ?? speechRate;
    fontSize = p.getDouble('fontSize') ?? fontSize;
    threshold = p.getDouble('threshold') ?? threshold;
    darkMode = p.getBool('darkMode') ?? darkMode;
    speakResults = p.getBool('speakResults') ?? speakResults;
    serverUrl = p.getString('serverUrl') ?? serverUrl;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString('language', language);
    await p.setDouble('speechRate', speechRate);
    await p.setDouble('fontSize', fontSize);
    await p.setDouble('threshold', threshold);
    await p.setBool('darkMode', darkMode);
    await p.setBool('speakResults', speakResults);
    await p.setString('serverUrl', serverUrl);
  }

  void update({String? language, double? speechRate, double? fontSize, double? threshold,
      bool? darkMode, bool? speakResults, String? serverUrl}) {
    this.language = language ?? this.language;
    this.speechRate = speechRate ?? this.speechRate;
    this.fontSize = fontSize ?? this.fontSize;
    this.threshold = threshold ?? this.threshold;
    this.darkMode = darkMode ?? this.darkMode;
    this.speakResults = speakResults ?? this.speakResults;
    this.serverUrl = serverUrl ?? this.serverUrl;
    notifyListeners();
    _save();
  }
}
