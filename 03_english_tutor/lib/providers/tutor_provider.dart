import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/tutor_character.dart';
import '../services/ai_service.dart';

class TutorProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  
  TutorCharacter _activeCharacter = TutorCharacter.defaultCharacters.first;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false; // Voice recording simulation
  
  // Settings configs
  String _mode = 'google';
  String _apiKey = '';
  String _ollamaUrl = AiService.defaultOllamaUrl;
  String _ollamaModel = AiService.defaultOllamaModel;

  TutorCharacter get activeCharacter => _activeCharacter;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  
  String get mode => _mode;
  String get apiKey => _apiKey;
  String get ollamaUrl => _ollamaUrl;
  String get ollamaModel => _ollamaModel;

  TutorProvider() {
    _loadSettings();
    _loadChatHistory(_activeCharacter);
  }

  // Load configuration settings
  Future<void> _loadSettings() async {
    final config = await _aiService.getConfig();
    _mode = config['mode'] ?? 'google';
    _apiKey = config['apiKey'] ?? '';
    _ollamaUrl = config['ollamaUrl'] ?? AiService.defaultOllamaUrl;
    _ollamaModel = config['ollamaModel'] ?? AiService.defaultOllamaModel;
    notifyListeners();
  }

  // Reload settings from screen
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  // Set active character and load its history
  Future<void> selectCharacter(TutorCharacter character) async {
    _activeCharacter = character;
    _isListening = false;
    notifyListeners();
    await _loadChatHistory(character);
  }

  // Get SharedPreferences key for chat history
  String _historyKey(String characterId) => 'chat_history_$characterId';

  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory(TutorCharacter character) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_historyKey(character.id));

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(jsonStr);
        _messages = decodedList.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (e) {
        print('Error parsing chat history: $e. Reverting to default.');
        _loadDefaultOpener(character);
      }
    } else {
      _loadDefaultOpener(character);
    }
    notifyListeners();
  }

  // Initialize with the character's default greeting
  void _loadDefaultOpener(TutorCharacter character) {
    _messages = [
      ChatMessage(
        id: 'opener_${character.id}',
        sender: 'tutor',
        text: character.exampleOpener,
        timestamp: DateTime.now(),
      )
    ];
  }

  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _messages.map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey(_activeCharacter.id), jsonEncode(list));
  }

  // Send message and get AI correction + reply
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();
    await _saveChatHistory();

    // Generate response using AI Service
    final result = await _aiService.generateResponse(_activeCharacter, _messages, text);

    GrammarCorrection? correction;
    if (result['corrected'] != null && result['explanation'] != null) {
      correction = GrammarCorrection(
        originalText: text,
        correctedText: result['corrected'],
        explanation: result['explanation'],
      );
    }

    final tutorMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'tutor',
      text: result['reply'],
      correction: correction,
      timestamp: DateTime.now(),
    );

    _messages.add(tutorMessage);
    _isLoading = false;
    notifyListeners();
    await _saveChatHistory();
  }

  // Clear chat history for the active character
  Future<void> resetChat() async {
    _messages.clear();
    _loadDefaultOpener(_activeCharacter);
    notifyListeners();
    await _saveChatHistory();
  }

  // Toggle voice simulation (micro-interaction)
  void toggleListening() {
    _isListening = !_isListening;
    notifyListeners();
  }

  // Stop listening explicitly
  void stopListening() {
    _isListening = false;
    notifyListeners();
  }

  // Simulate Speak / TTS playback
  void toggleTts(ChatMessage message) {
    // Stop all other playing messages
    for (var msg in _messages) {
      if (msg.id != message.id && msg.isPlaying) {
        msg.isPlaying = false;
      }
    }
    
    message.isPlaying = !message.isPlaying;
    notifyListeners();

    // Auto turn off after a simulation period (e.g. 4 seconds)
    if (message.isPlaying) {
      Future.delayed(const Duration(seconds: 4), () {
        if (message.isPlaying) {
          message.isPlaying = false;
          notifyListeners();
        }
      });
    }
  }
}
