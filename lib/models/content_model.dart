class ContentModel {
  final String contentId;
  final String type; // "dua" | "ziyarat" | "surah" | "aamal"
  final String title;
  final String arabicText;
  final String translationEn;
  final String translationUr;
  final String translationHi;
  final String translationGu;
  final String? audioUrl;
  final List<String> tags; // e.g. ["arbaeen", "muharram", "morning"]

  const ContentModel({
    required this.contentId,
    required this.type,
    required this.title,
    required this.arabicText,
    required this.translationEn,
    required this.translationUr,
    required this.translationHi,
    this.translationGu = '',
    this.audioUrl,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'type': type,
      'title': title,
      'arabic_text': arabicText,
      'translation_en': translationEn,
      'translation_ur': translationUr,
      'translation_hi': translationHi,
      'translation_gu': translationGu,
      'audio_url': audioUrl,
      'tags': tags,
    };
  }

  factory ContentModel.fromMap(Map<String, dynamic> map, String id) {
    return ContentModel(
      contentId: id,
      type: map['type'] as String? ?? 'dua',
      title: map['title'] as String? ?? '',
      arabicText: map['arabic_text'] as String? ?? '',
      translationEn: map['translation_en'] as String? ?? '',
      translationUr: map['translation_ur'] as String? ?? '',
      translationHi: map['translation_hi'] as String? ?? '',
      translationGu: map['translation_gu'] as String? ?? '',
      audioUrl: map['audio_url'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
