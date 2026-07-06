import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attraction.dart';
import '../models/attraction_data.dart';
import '../models/trip_preferences.dart';
import '../models/itinerary.dart';

class AiService {
  static const String keyMode = 'jeju_ai_mode'; // 'google', 'ollama', or 'mock'
  static const String keyApiKey = 'jeju_google_api_key';
  static const String keyOllamaUrl = 'jeju_ollama_url';
  static const String keyOllamaModel = 'jeju_ollama_model';

  static const String defaultOllamaUrl = 'http://localhost:11434';
  static const String defaultOllamaModel = 'gemma4:e2b';

  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // Save configurations
  Future<void> saveConfig({
    required String mode,
    required String apiKey,
    required String ollamaUrl,
    required String ollamaModel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyMode, mode);
    await prefs.setString(keyApiKey, apiKey);
    await prefs.setString(keyOllamaUrl, ollamaUrl);
    await prefs.setString(keyOllamaModel, ollamaModel);
  }

  // Load configurations
  Future<Map<String, String>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mode': prefs.getString(keyMode) ?? 'mock',
      'apiKey': prefs.getString(keyApiKey) ?? '',
      'ollamaUrl': prefs.getString(keyOllamaUrl) ?? defaultOllamaUrl,
      'ollamaModel': prefs.getString(keyOllamaModel) ?? defaultOllamaModel,
    };
  }

  // Create prompt for AI
  String _buildPrompt(TripPreferences prefs) {
    final compactAttractions = jejuAttractions.map((a) => {
      'id': a.id,
      'name': a.name,
      'koreanName': a.koreanName,
      'region': a.region,
      'category': a.category,
      'tags': a.tags,
    }).toList();

    return '''
당신은 최고의 제주도 여행 코디네이터 AI입니다. 사용자의 아래 여행 선호도를 반영하여, 제공된 100개의 제주도 관광명소 중에서 가장 알맞은 명소들을 선정하고 최적화된 일별 여정(일정)을 짜주세요.

[사용자 선호도]
- 여행 기간: ${prefs.duration}일
- 동행인: ${prefs.companion}
- 여행 페이스: ${prefs.pace} (${prefs.pace == 'Relaxed' ? '하루 3곳 내외 여유롭게' : prefs.pace == 'Balanced' ? '하루 4곳 내외 알차게' : '하루 5곳 내외 빽빽하게'})
- 선호 카테고리: ${prefs.styleCategories.join(', ')}
- 선호 지역: ${prefs.regionPreferences.join(', ')}
- 특별 요청 사항: "${prefs.shortTextQuery}"

[선택 가능한 100개 명소 리스트 (JSON)]
${jsonEncode(compactAttractions)}

[작성 규칙]
1. 반드시 제공된 100개 명소 리스트에 존재하는 관광지만 사용해야 합니다. (새로운 관광지를 임의로 만들어내지 마세요. 리스트에 있는 id를 정확히 매칭해야 합니다.)
2. 하루 일정은 지리적으로 동선이 꼬이지 않도록 구성해 주세요. (예: 1일차는 동부, 2일차는 남부 등 지역을 묶어서 구성하거나 인접한 곳 위주로 배치)
3. 각 일정의 'transitMinutesToNext'에는 다음 목적지까지의 예상 소요 시간(분)을 10~50분 사이로 기재해 주세요. (마지막 일정은 0분)
4. 응답은 아래 JSON 스키마를 엄격히 따라야 하며, 어떠한 마크다운 백틱(```json)이나 불필요한 공백/설명 없이 오직 순수한 JSON 문자열만 응답해야 합니다.

[응답 JSON 스키마]
{
  "title": "여행 일정 제목 (예: '동행인과 함께하는 감성 제주 3일')",
  "description": "전체 여정에 대한 따뜻하고 친절한 설명 (2~3문장)",
  "recommendedTheme": "대표 여행 테마 요약 (예: '힐링 & 액티비티')",
  "recommendedAttractionIds": ["관광지_id1", "관광지_id2", ...], // 선정된 모든 관광지 ID 목록
  "days": [
    {
      "dayNumber": 1,
      "title": "1일차 코스 주제 (예: '우도와 성산의 푸른 바다')",
      "spots": [
        {
          "attractionId": "관광지_ID (예: e_001)",
          "timeSlot": "시간대 (예: 오전, 점심, 오후, 저녁, 야간 중 하나)",
          "customNotes": "해당 명소에서 사용자가 즐기면 좋은 활동 팁이나 추천 이유 (2문장 내외)",
          "transitMinutesToNext": 20
        }
      ]
    }
  ]
}
''';
  }

  // Generate itinerary
  Future<TripItinerary> generatePlan(TripPreferences preferences) async {
    final config = await getConfig();
    final mode = config['mode'];
    final apiKey = config['apiKey'] ?? '';
    final ollamaUrl = config['ollamaUrl'] ?? defaultOllamaUrl;
    final ollamaModel = config['ollamaModel'] ?? defaultOllamaModel;

    if (mode == 'mock' || (mode == 'google' && apiKey.isEmpty)) {
      // Run offline planner immediately
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulate thinking
      return _generateMockPlan(preferences);
    }

    final prompt = _buildPrompt(preferences);
    String rawResponse = '';

    try {
      if (mode == 'google') {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );
        final response = await model.generateContent([Content.text(prompt)]);
        rawResponse = response.text ?? '';
      } else if (mode == 'ollama') {
        final cleanUrl = ollamaUrl.endsWith('/') ? ollamaUrl.substring(0, ollamaUrl.length - 1) : ollamaUrl;
        final response = await http.post(
          Uri.parse('$cleanUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': ollamaModel,
            'prompt': prompt,
            'stream': false,
            'format': 'json',
          }),
        ).timeout(const Duration(seconds: 40));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          rawResponse = decoded['response'] ?? '';
        } else {
          throw Exception('Ollama API Error: ${response.statusCode}');
        }
      }

      rawResponse = _cleanJson(rawResponse);
      final Map<String, dynamic> jsonMap = jsonDecode(rawResponse);
      return TripItinerary.fromJson(jsonMap, jejuAttractions);
    } catch (e) {
      print('AI generation error: $e. Falling back to offline heuristic planner.');
      return _generateMockPlan(preferences);
    }
  }

  String _cleanJson(String source) {
    var cleaned = source.trim();
    if (cleaned.startsWith('```')) {
      final startIndex = cleaned.indexOf('{');
      final endIndex = cleaned.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
      }
    }
    return cleaned;
  }

  // --- OFFLINE HEURISTIC GEOGRAPHICAL TSP PLANNER ---
  TripItinerary _generateMockPlan(TripPreferences prefs) {
    // 1. Score and Filter Attractions
    final scoredAttractions = <MapEntry<Attraction, double>>[];
    final queryTerms = prefs.shortTextQuery.toLowerCase().split(' ').where((t) => t.isNotEmpty).toList();

    for (final attraction in jejuAttractions) {
      double score = 0.0;

      // Region match (+5.0 points)
      if (prefs.regionPreferences.contains(attraction.region)) {
        score += 5.0;
      }

      // Category match (+3.0 points per category)
      if (prefs.styleCategories.contains(attraction.category)) {
        score += 3.0;
      }

      // Tag match (+1.0 point per matching tag)
      for (final tag in attraction.tags) {
        if (prefs.styleCategories.contains(tag) || 
            (prefs.shortTextQuery.isNotEmpty && prefs.shortTextQuery.contains(tag))) {
          score += 1.0;
        }
      }

      // Short text keyword match (+10.0 points)
      if (queryTerms.isNotEmpty) {
        final attractionText = '${attraction.name} ${attraction.koreanName} ${attraction.description} ${attraction.tags.join(" ")}'.toLowerCase();
        for (final term in queryTerms) {
          if (attractionText.contains(term)) {
            score += 10.0;
          }
        }
      }

      scoredAttractions.add(MapEntry(attraction, score));
    }

    // Sort by score descending
    scoredAttractions.sort((a, b) => b.value.compareTo(a.value));
    final sortedList = scoredAttractions.map((e) => e.key).toList();

    // 2. Group by region
    final Map<String, List<Attraction>> regionGroups = {
      'North': [],
      'East': [],
      'South': [],
      'West': [],
    };
    for (final attraction in sortedList) {
      regionGroups[attraction.region]?.add(attraction);
    }

    // 3. Assign regions to days
    // We want to avoid hopping from east to west in one day.
    // We determine which regions are selected by the user, or default to all.
    final availableRegions = prefs.regionPreferences.isNotEmpty 
        ? List<String>.from(prefs.regionPreferences) 
        : ['North', 'East', 'South', 'West'];

    // Map each day to a region sequence
    final dayRegions = <String>[];
    for (int d = 0; d < prefs.duration; d++) {
      // Distribute regions sequentially
      final region = availableRegions[d % availableRegions.length];
      dayRegions.add(region);
    }

    // 4. Determine items per day based on pace
    int spotsPerDay = 4;
    if (prefs.pace == 'Relaxed') spotsPerDay = 3;
    if (prefs.pace == 'Packed') spotsPerDay = 5;

    final days = <ItineraryDay>[];
    final selectedIds = <String>[];
    
    // Starting coordinates (Jeju Airport)
    double currentLat = 33.5113;
    double currentLng = 126.4930;

    for (int d = 0; d < prefs.duration; d++) {
      final targetRegion = dayRegions[d];
      final dayCandidates = regionGroups[targetRegion] ?? [];

      // Remove already selected spots
      final pool = dayCandidates.where((a) => !selectedIds.contains(a.id)).toList();

      // If pool is empty, grab from general sorted list
      if (pool.isEmpty) {
        pool.addAll(sortedList.where((a) => !selectedIds.contains(a.id)));
      }

      // Greedy nearest-neighbor TSP selection for this day
      final daySpots = <Attraction>[];
      for (int i = 0; i < spotsPerDay; i++) {
        if (pool.isEmpty) break;
        
        // Find nearest spot to current coordinates
        int bestIndex = 0;
        double minDistance = double.maxFinite;

        for (int k = 0; k < pool.length; k++) {
          final dist = _haversineDistance(currentLat, currentLng, pool[k].latitude, pool[k].longitude);
          if (dist < minDistance) {
            minDistance = dist;
            bestIndex = k;
          }
        }

        final selected = pool.removeAt(bestIndex);
        daySpots.add(selected);
        selectedIds.add(selected.id);
        
        // Update current coordinates
        currentLat = selected.latitude;
        currentLng = selected.longitude;
      }

      // Construct spots with timeslots and custom notes
      final itinerarySpots = <ItinerarySpot>[];
      final timeSlots = _getTimeSlots(spotsPerDay);

      for (int i = 0; i < daySpots.length; i++) {
        final spot = daySpots[i];
        final nextSpot = i < daySpots.length - 1 ? daySpots[i + 1] : null;
        
        // Transit calculation
        int transitTime = 0;
        if (nextSpot != null) {
          final distanceKm = _haversineDistance(spot.latitude, spot.longitude, nextSpot.latitude, nextSpot.longitude);
          // 1 km ≈ 2 minutes of driving/bus travel
          transitTime = max(10, min(60, (distanceKm * 2.0).round()));
        }

        itinerarySpots.add(ItinerarySpot(
          attraction: spot,
          timeSlot: timeSlots[i],
          customNotes: _generateCustomNote(spot, prefs.companion),
          transitMinutesToNext: transitTime,
        ));
      }

      // Choose a beautiful day title
      final regionKoName = targetRegion == 'North' ? '제주 시내 & 북부' : targetRegion == 'East' ? '성산 & 동부 에메랄드' : targetRegion == 'South' ? '서귀포 & 남부 폭포' : '애월 & 서부 Sunset';
      days.add(ItineraryDay(
        dayNumber: d + 1,
        title: '$regionKoName 테마 투어',
        spots: itinerarySpots,
      ));
    }

    // Prepare overview descriptions
    final companionName = prefs.companion == 'Solo' ? '나홀로 떠나는' : prefs.companion == 'Couple' ? '연인과 함께하는' : prefs.companion == 'Family' ? '가족 모두가 즐기는' : '친구들과 함께하는';
    final categoriesName = prefs.styleCategories.map((c) => c == 'Nature' ? '자연풍경' : c == 'Healing' ? '힐링휴식' : c == 'CafeFood' ? '카페투어' : c == 'Activity' ? '레저체험' : '역사문화').join(', ');
    final title = '$companionName 제주 $categoriesName ${prefs.duration}일 여정';
    final description = '인공지능이 제주의 약 100개 명소를 분석하여, ${prefs.companion} 여행에 최적화된 동선과 일정을 설계했습니다. 지리적 꼬임이 없도록 동선 효율성을 향상시켰으며, 카카오맵 바로가기를 통해 렌터카나 대중교통으로 손쉽게 길찾기가 가능합니다.';

    return TripItinerary(
      title: title,
      description: description,
      recommendedTheme: categoriesName,
      days: days,
      recommendedAttractionIds: selectedIds,
    );
  }

  // Haversine formula to compute distance in km
  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Earth radius in km
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  // Get timeslots list
  List<String> _getTimeSlots(int count) {
    if (count == 3) return ['오전', '오후', '저녁'];
    if (count == 4) return ['오전', '점심', '오후', '저녁'];
    return ['오전', '점심', '오후', '저녁', '야간'];
  }

  // Generate nice contextual notes
  String _generateCustomNote(Attraction attraction, String companion) {
    final companionContext = companion == 'Solo' ? '혼자 사색하기 좋고 한적한 분위기가 돋보입니다.' : companion == 'Couple' ? '연인과 함께 로맨틱한 인생샷을 남기기에 완벽합니다.' : companion == 'Family' ? '남녀노소 부모님과 아이들 모두 편하게 관람할 수 있습니다.' : '친구들과 웃고 즐기며 특별한 추억을 만들기 좋습니다.';
    
    if (attraction.category == 'Nature') {
      return '웅장한 제주의 천혜 자연경관을 만끽할 수 있습니다. $companionContext';
    } else if (attraction.category == 'Healing') {
      return '피톤치드가 느껴지는 삼나무 숲길이나 해안을 걸으며 몸과 마음을 정화해 보세요. $companionContext';
    } else if (attraction.category == 'CafeFood') {
      return '제주의 특색이 담긴 맛있는 디저트나 요리를 먹으며 예쁜 오션뷰를 즐겨 보세요. $companionContext';
    } else if (attraction.category == 'Activity') {
      return '생생한 제주를 체험하고 액티비티를 통해 지루할 틈 없는 신나는 추억을 쌓아보세요. $companionContext';
    } else {
      return '제주 고유의 풍습이나 문화, 역사적 명소를 돌아보며 유익한 시간을 보내보세요. $companionContext';
    }
  }
}
