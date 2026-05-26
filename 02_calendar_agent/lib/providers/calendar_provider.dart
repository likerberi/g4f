import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event.dart';
import '../services/ai_service.dart';

class CalendarProvider extends ChangeNotifier {
  static const String keyEventsList = 'calendar_events_list';

  final List<CalendarEvent> _allEvents = [];
  final Map<DateTime, List<CalendarEvent>> _groupedEvents = {};
  bool _isLoading = false;
  CalendarEvent? _lastParsedEvent;

  List<CalendarEvent> get allEvents => List.unmodifiable(_allEvents);
  Map<DateTime, List<CalendarEvent>> get groupedEvents => _groupedEvents;
  bool get isLoading => _isLoading;
  CalendarEvent? get lastParsedEvent => _lastParsedEvent;

  final AiService _aiService = AiService();

  CalendarProvider() {
    loadEvents();
  }

  // Normalize date to clear out hour, minute, second, millisecond for grouping
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Load events from SharedPreferences
  Future<void> loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(keyEventsList) ?? [];

      _allEvents.clear();
      _groupedEvents.clear();

      for (final rawJson in rawList) {
        final event = CalendarEvent.fromJson(rawJson);
        _allEvents.add(event);

        final normalized = _normalizeDate(event.date);
        if (_groupedEvents[normalized] == null) {
          _groupedEvents[normalized] = [];
        }
        _groupedEvents[normalized]!.add(event);
      }

      // Sort events on each day by time
      _groupedEvents.forEach((date, list) {
        list.sort((a, b) => a.time.compareTo(b.time));
      });

      // Sort all events descending by created date
      _allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      print('Error loading calendar events: $e');
    }
  }

  // Save all events to SharedPreferences
  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = _allEvents.map((e) => e.toJson()).toList();
      await prefs.setStringList(keyEventsList, rawList);
    } catch (e) {
      print('Error saving calendar events: $e');
    }
  }

  // Add event directly
  Future<void> addEvent(CalendarEvent event) async {
    _allEvents.add(event);

    final normalized = _normalizeDate(event.date);
    if (_groupedEvents[normalized] == null) {
      _groupedEvents[normalized] = [];
    }
    _groupedEvents[normalized]!.add(event);
    _groupedEvents[normalized]!.sort((a, b) => a.time.compareTo(b.time));

    // Sort all events
    _allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _saveEvents();
    notifyListeners();
  }

  // Delete event by ID
  Future<void> deleteEvent(String id) async {
    _allEvents.removeWhere((e) => e.id == id);

    // Rebuild group map
    _groupedEvents.clear();
    for (final event in _allEvents) {
      final normalized = _normalizeDate(event.date);
      if (_groupedEvents[normalized] == null) {
        _groupedEvents[normalized] = [];
      }
      _groupedEvents[normalized]!.add(event);
    }

    _groupedEvents.forEach((date, list) {
      list.sort((a, b) => a.time.compareTo(b.time));
    });

    await _saveEvents();
    notifyListeners();
  }

  // Parse natural language using AI service
  Future<CalendarEvent?> parseNaturalLanguage(String text) async {
    if (text.trim().isEmpty) return null;

    _isLoading = true;
    _lastParsedEvent = null;
    notifyListeners();

    try {
      final event = await _aiService.parseEvent(text);
      _lastParsedEvent = event;
      notifyListeners();
      return event;
    } catch (e) {
      print('Error parsing schedule text: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Confirm and save the last parsed event
  Future<void> confirmLastParsedEvent() async {
    if (_lastParsedEvent != null) {
      await addEvent(_lastParsedEvent!);
      _lastParsedEvent = null;
      notifyListeners();
    }
  }

  // Update properties of the last parsed event before confirming
  void updateLastParsedEvent({
    String? title,
    DateTime? date,
    String? time,
    String? location,
  }) {
    if (_lastParsedEvent != null) {
      _lastParsedEvent = CalendarEvent(
        id: _lastParsedEvent!.id,
        title: title ?? _lastParsedEvent!.title,
        date: date ?? _lastParsedEvent!.date,
        time: time ?? _lastParsedEvent!.time,
        location: location ?? _lastParsedEvent!.location,
        originalText: _lastParsedEvent!.originalText,
        createdAt: _lastParsedEvent!.createdAt,
      );
      notifyListeners();
    }
  }

  // Clear suggestions
  void clearSuggestedEvent() {
    _lastParsedEvent = null;
    notifyListeners();
  }

  // Get events for a specific day
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _groupedEvents[_normalizeDate(day)] ?? [];
  }
}
