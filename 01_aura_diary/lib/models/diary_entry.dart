import 'dart:convert';

class DiaryEntry {
  final String id;
  final String content;
  final DateTime date;
  final String sentiment;
  final String sentimentColorHex;
  final String replyText;
  final String advice;

  DiaryEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.sentiment,
    required this.sentimentColorHex,
    required this.replyText,
    required this.advice,
  });

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
      'sentiment': sentiment,
      'sentimentColorHex': sentimentColorHex,
      'replyText': replyText,
      'advice': advice,
    };
  }

  // Convert from Map for deserialization
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      sentiment: map['sentiment'] ?? '평온',
      sentimentColorHex: map['sentimentColorHex'] ?? '#8E9AAF',
      replyText: map['replyText'] ?? '',
      advice: map['advice'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DiaryEntry.fromJson(String source) => DiaryEntry.fromMap(json.decode(source));
}
