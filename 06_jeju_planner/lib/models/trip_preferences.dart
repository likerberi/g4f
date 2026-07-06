class TripPreferences {
  final int duration; // 2, 3, 4, 5 days
  final String companion; // 'Solo', 'Couple', 'Family', 'Friends'
  final String pace; // 'Relaxed' (3 spots/day), 'Balanced' (4 spots/day), 'Packed' (5 spots/day)
  final List<String> styleCategories; // ['Nature', 'Activity', 'Culture', 'CafeFood', 'Healing']
  final List<String> regionPreferences; // ['North', 'East', 'South', 'West']
  final String shortTextQuery; // Short answer inputs

  const TripPreferences({
    required this.duration,
    required this.companion,
    required this.pace,
    required this.styleCategories,
    required this.regionPreferences,
    required this.shortTextQuery,
  });

  TripPreferences copyWith({
    int? duration,
    String? companion,
    String? pace,
    List<String>? styleCategories,
    List<String>? regionPreferences,
    String? shortTextQuery,
  }) {
    return TripPreferences(
      duration: duration ?? this.duration,
      companion: companion ?? this.companion,
      pace: pace ?? this.pace,
      styleCategories: styleCategories ?? this.styleCategories,
      regionPreferences: regionPreferences ?? this.regionPreferences,
      shortTextQuery: shortTextQuery ?? this.shortTextQuery,
    );
  }

  factory TripPreferences.empty() {
    return const TripPreferences(
      duration: 3,
      companion: 'Couple',
      pace: 'Balanced',
      styleCategories: ['Nature', 'Healing'],
      regionPreferences: ['East', 'South'],
      shortTextQuery: '',
    );
  }
}
