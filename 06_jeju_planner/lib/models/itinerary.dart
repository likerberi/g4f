import 'attraction.dart';

class ItinerarySpot {
  final Attraction attraction;
  final String timeSlot; // 'Morning', 'Lunch', 'Afternoon', 'Dinner', 'Evening'
  final String customNotes; // AI recommended activity here
  final int transitMinutesToNext; // Approximate transit time

  const ItinerarySpot({
    required this.attraction,
    required this.timeSlot,
    required this.customNotes,
    this.transitMinutesToNext = 0,
  });

  factory ItinerarySpot.fromJson(Map<String, dynamic> json, List<Attraction> allAttractions) {
    final attractionId = json['attractionId'] as String;
    final attraction = allAttractions.firstWhere(
      (a) => a.id == attractionId,
      orElse: () => Attraction(
        id: attractionId,
        name: json['name'] ?? 'Unknown Attraction',
        koreanName: json['koreanName'] ?? '알 수 없는 명소',
        description: '',
        region: 'North',
        category: 'Nature',
        tags: const [],
        latitude: 33.4996,
        longitude: 126.5312,
        kakaoMapUrl: '',
      ),
    );
    return ItinerarySpot(
      attraction: attraction,
      timeSlot: json['timeSlot'] as String,
      customNotes: json['customNotes'] as String? ?? '',
      transitMinutesToNext: json['transitMinutesToNext'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'attractionId': attraction.id,
        'timeSlot': timeSlot,
        'customNotes': customNotes,
        'transitMinutesToNext': transitMinutesToNext,
      };
}

class ItineraryDay {
  final int dayNumber;
  final String title; // E.g., '동부 해안 힐링 투어'
  final List<ItinerarySpot> spots;

  const ItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.spots,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json, List<Attraction> allAttractions) {
    final spotsList = json['spots'] as List;
    return ItineraryDay(
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String? ?? 'Day ${json['dayNumber']}',
      spots: spotsList.map((s) => ItinerarySpot.fromJson(s, allAttractions)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'title': title,
        'spots': spots.map((s) => s.toJson()).toList(),
      };
}

class TripItinerary {
  final String title;
  final String description;
  final String recommendedTheme;
  final List<ItineraryDay> days;
  final List<String> recommendedAttractionIds;

  const TripItinerary({
    required this.title,
    required this.description,
    required this.recommendedTheme,
    required this.days,
    required this.recommendedAttractionIds,
  });

  factory TripItinerary.fromJson(Map<String, dynamic> json, List<Attraction> allAttractions) {
    final daysList = json['days'] as List;
    return TripItinerary(
      title: json['title'] as String? ?? '제주 감성 여행 플랜',
      description: json['description'] as String? ?? 'AI가 맞춤 추천한 제주도 여정입니다.',
      recommendedTheme: json['recommendedTheme'] as String? ?? '힐링 & 네이처',
      days: daysList.map((d) => ItineraryDay.fromJson(d, allAttractions)).toList(),
      recommendedAttractionIds: List<String>.from(json['recommendedAttractionIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'recommendedTheme': recommendedTheme,
        'days': days.map((d) => d.toJson()).toList(),
        'recommendedAttractionIds': recommendedAttractionIds,
      };
}
