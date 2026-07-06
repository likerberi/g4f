import 'package:flutter/material.dart';
import '../models/trip_preferences.dart';
import '../models/itinerary.dart';
import '../services/ai_service.dart';

class PlannerProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  TripPreferences _preferences = TripPreferences.empty();
  TripItinerary? _itinerary;
  bool _isLoading = false;
  String _loadingMessage = '';

  TripPreferences get preferences => _preferences;
  TripItinerary? get itinerary => _itinerary;
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  // Update preferences
  void updatePreferences(TripPreferences newPrefs) {
    _preferences = newPrefs;
    notifyListeners();
  }

  // Generate travel plan
  Future<void> generatePlan() async {
    _isLoading = true;
    _itinerary = null;
    notifyListeners();

    // Setup sequence of loading messages to wow the user
    final messages = [
      '제주도 100대 대표 관광지 데이터베이스 조회 중...',
      '사용자의 여행 스타일 성향 분석 중...',
      '동행인 맞춤형 장소 추천 가중치 부여 중...',
      '지리적 동선 최적화 및 최단 경로(TSP) 알고리즘 구동 중...',
      '하루 일정별 상세 활동 가이드 및 이동 소요 시간 추정 중...',
      '감성적인 제주 맞춤 플래너 생성 완료!',
    ];

    int messageIndex = 0;
    _loadingMessage = messages[messageIndex];
    notifyListeners();

    // Cycle through messages while generating the plan
    final timer = Stream.periodic(const Duration(milliseconds: 700), (count) => count);
    final subscription = timer.listen((_) {
      if (messageIndex < messages.length - 2) {
        messageIndex++;
        _loadingMessage = messages[messageIndex];
        notifyListeners();
      }
    });

    try {
      _itinerary = await _aiService.generatePlan(_preferences);
    } catch (e) {
      print('Provider Error: $e');
    } finally {
      subscription.cancel();
      _loadingMessage = messages.last;
      notifyListeners();
      
      // Let the final message show briefly
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current itinerary and start over
  void reset() {
    _itinerary = null;
    _isLoading = false;
    _loadingMessage = '';
    notifyListeners();
  }
}
