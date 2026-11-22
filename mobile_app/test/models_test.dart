import 'package:flutter_test/flutter_test.dart';
import 'package:sign_language_translator/models/history_entry.dart';
import 'package:sign_language_translator/models/prediction.dart';
import 'package:sign_language_translator/models/sign.dart';

void main() {
  test('Prediction parses a recognized response', () {
    final p = Prediction.fromJson({'label': 'Hello', 'confidence': 0.93, 'recognized': true});
    expect(p.label, 'Hello');
    expect(p.recognized, isTrue);
    expect(p.confidence, closeTo(0.93, 1e-9));
  });

  test('Prediction parses a not-recognized response', () {
    final p = Prediction.fromJson({'label': null, 'confidence': 0.5, 'recognized': false});
    expect(p.label, isNull);
    expect(p.recognized, isFalse);
  });

  test('Sign.fromJson maps server keys', () {
    final s = Sign.fromJson({'id': 1, 'label_en': 'Thank you', 'label_ar': 'شكرًا', 'category': 'General'});
    expect(s.labelEn, 'Thank you');
    expect(Sign.fallback.length, 8);
  });

  test('HistoryEntry round-trips through a map', () {
    final e = HistoryEntry(label: 'Help', confidence: 0.9, createdAt: DateTime.utc(2026, 1, 1));
    final back = HistoryEntry.fromMap(e.toMap());
    expect(back.label, 'Help');
    expect(back.createdAt, DateTime.utc(2026, 1, 1));
  });
}
