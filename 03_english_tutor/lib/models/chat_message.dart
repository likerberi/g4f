class GrammarCorrection {
  final String originalText;
  final String correctedText;
  final String explanation; // Korean explanation of the grammar rule

  GrammarCorrection({
    required this.originalText,
    required this.correctedText,
    required this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'correctedText': correctedText,
      'explanation': explanation,
    };
  }

  factory GrammarCorrection.fromJson(Map<String, dynamic> json) {
    return GrammarCorrection(
      originalText: json['originalText'] ?? '',
      correctedText: json['correctedText'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String sender; // 'user' or 'tutor'
  final String text;
  final GrammarCorrection? correction;
  final DateTime timestamp;
  bool isPlaying; // TTS playing state helper

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.correction,
    required this.timestamp,
    this.isPlaying = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'correction': correction?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final correctionJson = json['correction'];
    return ChatMessage(
      id: json['id'] ?? '',
      sender: json['sender'] ?? 'tutor',
      text: json['text'] ?? '',
      correction: correctionJson != null ? GrammarCorrection.fromJson(Map<String, dynamic>.from(correctionJson)) : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
