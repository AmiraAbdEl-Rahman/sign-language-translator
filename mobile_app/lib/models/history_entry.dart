class HistoryEntry {
  final int? id;
  final String label;
  final double confidence;
  final DateTime createdAt;

  const HistoryEntry({this.id, required this.label, required this.confidence, required this.createdAt});

  Map<String, Object?> toMap() => {
        'id': id,
        'label': label,
        'confidence': confidence,
        'created_at': createdAt.toIso8601String(),
      };

  factory HistoryEntry.fromMap(Map<String, Object?> m) => HistoryEntry(
        id: m['id'] as int?,
        label: m['label'] as String,
        confidence: (m['confidence'] as num).toDouble(),
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
