class Attraction {
  final String id;
  final String name;
  final String koreanName;
  final String description;
  final String region; // 'North', 'East', 'South', 'West'
  final String category; // 'Nature', 'Activity', 'Culture', 'CafeFood', 'Healing'
  final List<String> tags;
  final double latitude;
  final double longitude;
  final String kakaoMapUrl;

  const Attraction({
    required this.id,
    required this.name,
    required this.koreanName,
    required this.description,
    required this.region,
    required this.category,
    required this.tags,
    required this.latitude,
    required this.longitude,
    required this.kakaoMapUrl,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'] as String,
      name: json['name'] as String,
      koreanName: json['koreanName'] as String,
      description: json['description'] as String,
      region: json['region'] as String,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      kakaoMapUrl: json['kakaoMapUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'koreanName': koreanName,
        'description': description,
        'region': region,
        'category': category,
        'tags': tags,
        'latitude': latitude,
        'longitude': longitude,
        'kakaoMapUrl': kakaoMapUrl,
      };
}
