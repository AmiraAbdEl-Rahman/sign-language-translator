class Sign {
  final int id;
  final String labelEn;
  final String labelAr;
  final String category;

  const Sign({required this.id, required this.labelEn, required this.labelAr, required this.category});

  factory Sign.fromJson(Map<String, dynamic> j) => Sign(
        id: j['id'] as int,
        labelEn: j['label_en'] as String,
        labelAr: j['label_ar'] as String,
        category: j['category'] as String,
      );

  /// Used when the server cannot be reached so the vocabulary screen still works.
  static const fallback = [
    Sign(id: 0, labelEn: 'Hello', labelAr: 'مرحبًا', category: 'General'),
    Sign(id: 1, labelEn: 'Thank you', labelAr: 'شكرًا', category: 'General'),
    Sign(id: 2, labelEn: 'Yes', labelAr: 'نعم', category: 'General'),
    Sign(id: 3, labelEn: 'No', labelAr: 'لا', category: 'General'),
    Sign(id: 4, labelEn: 'Doctor', labelAr: 'طبيب', category: 'Medical'),
    Sign(id: 5, labelEn: 'Pain', labelAr: 'ألم', category: 'Medical'),
    Sign(id: 6, labelEn: 'Help', labelAr: 'مساعدة', category: 'Medical'),
    Sign(id: 7, labelEn: 'Water', labelAr: 'ماء', category: 'Medical'),
  ];
}
