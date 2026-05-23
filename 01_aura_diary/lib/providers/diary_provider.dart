import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../services/ai_service.dart';

class DiaryProvider extends ChangeNotifier {
  static const String keyEntriesList = 'diary_entries_list';

  final List<DiaryEntry> _entries = [];
  bool _isLoading = false;
  DiaryEntry? _currentAnalysisResult;

  List<DiaryEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  DiaryEntry? get currentAnalysisResult => _currentAnalysisResult;

  final AiService _aiService = AiService();

  DiaryProvider() {
    loadEntries();
  }

  // Load saved entries from SharedPreferences
  Future<void> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(keyEntriesList) ?? [];
      
      _entries.clear();
      for (final rawJson in rawList) {
        _entries.add(DiaryEntry.fromJson(rawJson));
      }
      
      // Sort entries by date descending (latest first)
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print('Error loading entries: $e');
    }
  }

  // Save entries list to SharedPreferences
  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = _entries.map((e) => e.toJson()).toList();
      await prefs.setStringList(keyEntriesList, rawList);
    } catch (e) {
      print('Error saving entries: $e');
    }
  }

  // Analyze a new diary entry and save it
  Future<DiaryEntry?> analyzeAndAddEntry(String content) async {
    if (content.trim().isEmpty) return null;

    _isLoading = true;
    _currentAnalysisResult = null;
    notifyListeners();

    try {
      final entry = await _aiService.analyzeDiary(content);
      _entries.insert(0, entry); // Insert at the beginning (latest first)
      _currentAnalysisResult = entry;
      await _saveEntries();
      notifyListeners();
      return entry;
    } catch (e) {
      print('Error during analysis: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a diary entry
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((element) => element.id == id);
    await _saveEntries();
    notifyListeners();
  }

  // Clear current active analysis result
  void clearCurrentResult() {
    _currentAnalysisResult = null;
    notifyListeners();
  }
}
