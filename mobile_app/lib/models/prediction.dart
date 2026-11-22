class Prediction {
  final String? label;
  final double confidence;
  final bool recognized;

  const Prediction({this.label, required this.confidence, required this.recognized});

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        label: json['label'] as String?,
        confidence: (json['confidence'] as num).toDouble(),
        recognized: json['recognized'] as bool? ?? json['label'] != null,
      );
}
