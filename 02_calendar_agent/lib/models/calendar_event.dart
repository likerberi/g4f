import 'dart:convert';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final String originalText;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.originalText,
    required this.createdAt,
  });

  // Convert CalendarEvent to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'originalText': originalText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create CalendarEvent from Map
  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '새 일정',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      time: map['time'] ?? '12:00',
      location: map['location'] ?? '',
      originalText: map['originalText'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON String
  String toJson() => jsonEncode(toMap());

  // Create from JSON String
  factory CalendarEvent.fromJson(String source) => CalendarEvent.fromMap(jsonDecode(source));
}
