class GeneratedAudio {
  final String id;
  final String audioUrl;
  final String text;
  final String speaker;
  final String language;
  final DateTime createdAt;

  GeneratedAudio({
    required this.id,
    required this.audioUrl,
    required this.text,
    required this.speaker,
    required this.language,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'audioUrl': audioUrl,
    'text': text,
    'speaker': speaker,
    'language': language,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GeneratedAudio.fromJson(Map<String, dynamic> json) => GeneratedAudio(
    id: json['id'],
    audioUrl: json['audioUrl'],
    text: json['text'],
    speaker: json['speaker'],
    language: json['language'],
    createdAt: DateTime.parse(json['createdAt']),
  );
} 