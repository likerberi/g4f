import 'dart:convert';

class GalleryImage {
  final String id;
  final String imagePath; // Local file path OR web URL (for sample images)
  final String caption;
  final List<String> tags;
  final DateTime dateAdded;
  final double searchScore; // Non-serialized score used for search matching (0.0 to 1.0)
  final bool isSample; // Whether it is a preset Unsplash image
  final bool isPending; // Whether the image is currently in the background queue awaiting analysis

  GalleryImage({
    required this.id,
    required this.imagePath,
    required this.caption,
    required this.tags,
    required this.dateAdded,
    this.searchScore = 0.0,
    this.isSample = false,
    this.isPending = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'caption': caption,
      'tags': tags,
      'dateAdded': dateAdded.toIso8601String(),
      'isSample': isSample,
      'isPending': isPending,
    };
  }

  factory GalleryImage.fromMap(Map<String, dynamic> map) {
    return GalleryImage(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      caption: map['caption'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      dateAdded: DateTime.parse(map['dateAdded'] ?? DateTime.now().toIso8601String()),
      isSample: map['isSample'] ?? false,
      isPending: map['isPending'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory GalleryImage.fromJson(String source) => GalleryImage.fromMap(json.decode(source));

  GalleryImage copyWith({
    String? id,
    String? imagePath,
    String? caption,
    List<String>? tags,
    DateTime? dateAdded,
    double? searchScore,
    bool? isSample,
    bool? isPending,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      dateAdded: dateAdded ?? this.dateAdded,
      searchScore: searchScore ?? this.searchScore,
      isSample: isSample ?? this.isSample,
      isPending: isPending ?? this.isPending,
    );
  }
}
