import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import '../models/gallery_image.dart';
import '../services/ai_service.dart';

class GalleryProvider extends ChangeNotifier {
  static const String keyImagesList = 'gallery_images_list';

  final List<GalleryImage> _images = [];
  final List<GalleryImage> _searchResults = [];
  final List<GalleryImage> _backgroundQueue = [];
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isBackgroundWorkerRunning = false;
  String _searchQuery = '';

  // Getters
  List<GalleryImage> get images => List.unmodifiable(_images);
  List<GalleryImage> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isBackgroundWorkerRunning => _isBackgroundWorkerRunning;
  String get searchQuery => _searchQuery;
  int get pendingCount => _images.where((img) => img.isPending).length;

  final AiService _aiService = AiService();

  GalleryProvider() {
    loadImages();
  }

  // Load saved images from SharedPreferences
  Future<void> loadImages() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(keyImagesList) ?? [];
      
      _images.clear();
      for (final rawJson in rawList) {
        _images.add(GalleryImage.fromJson(rawJson));
      }
      
      // Sort images by date added (latest first)
      _images.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      
      // Auto-resume background indexing for any images that were left in pending state
      final pendingImages = _images.where((img) => img.isPending).toList();
      if (pendingImages.isNotEmpty) {
        _backgroundQueue.addAll(pendingImages);
        _processBackgroundQueue();
      }
    } catch (e) {
      print('Error loading gallery images: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save images list to SharedPreferences
  Future<void> _saveImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = _images.map((e) => e.toJson()).toList();
      await prefs.setStringList(keyImagesList, rawList);
    } catch (e) {
      print('Error saving gallery images: $e');
    }
  }

  // Seed sample images for immediate search capability
  Future<void> importSampleImages() async {
    _isLoading = true;
    notifyListeners();

    final samples = [
      GalleryImage(
        id: 'sample_beach',
        imagePath: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop',
        caption: '눈부시게 맑고 화창한 날, 드넓게 펼쳐진 황금빛 백사장과 에메랄드빛 바다가 어우러진 해변 풍경입니다. 하얀 거품을 일으키며 부드럽게 밀려오는 파도가 인상적이며, 하늘에는 구름 한 점 없이 투명한 파란색을 띠고 있습니다. 평화롭고 따뜻한 여름날의 휴양지 감성이 고스란히 담겨 있어 보는 것만으로도 힐링되는 사진입니다.',
        tags: ['바다', '해변', '백사장', '파도', '파란하늘', '휴양지', '여름', '힐링', '풍경'],
        dateAdded: DateTime.now().subtract(const Duration(minutes: 5)),
        isSample: true,
      ),
      GalleryImage(
        id: 'sample_dog',
        imagePath: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800&auto=format&fit=crop',
        caption: '싱그러운 초록빛 잔디밭 위에 엎드려 카메라를 향해 혀를 살짝 내밀고 해맑게 웃고 있는 귀여운 골든 리트리버 강아지입니다. 복슬복슬한 황금빛 털이 햇살을 받아 반짝이고 있으며, 호기심 어린 눈망울과 처진 귀가 매력적입니다. 반려동물의 행복하고 평화로운 일상을 따뜻하게 포착해낸 사진입니다.',
        tags: ['강아지', '골든리트리버', '반려동물', '잔디밭', '동물', '귀여움', '미소', '햇살', '일상'],
        dateAdded: DateTime.now().subtract(const Duration(minutes: 4)),
        isSample: true,
      ),
      GalleryImage(
        id: 'sample_forest',
        imagePath: 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800&auto=format&fit=crop',
        caption: '울창하고 깊은 숲속을 가로지르는 고요한 흙길 산책로입니다. 길 주변으로는 키가 큰 나무들이 빽빽하게 우거져 있으며, 나뭇잎 사이로 따스한 아침 햇살이 갈라져 내려와 숲 바닥을 부드럽게 비추고 있습니다. 자연의 싱그러운 초록색 에너지가 느껴지며, 고요하고 평화로운 피톤치드 가득한 아침 산책의 정취를 자아냅니다.',
        tags: ['숲', '산책로', '나무', '햇살', '초록빛', '자연', '피톤치드', '아침', '고요함', '풍경'],
        dateAdded: DateTime.now().subtract(const Duration(minutes: 3)),
        isSample: true,
      ),
      GalleryImage(
        id: 'sample_workspace',
        imagePath: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&auto=format&fit=crop',
        caption: '현대적이고 깔끔하게 정리된 개발자의 작업 공간입니다. 검은색 화면 위에 하이라이트된 소스코드가 적혀 있는 노트북이 열려 있고, 옆에는 따뜻한 검은색 커피가 담긴 머그잔, 가죽 다이어리, 그리고 하얀 펜이 놓여 있습니다. 세련된 그레이 톤의 책상 위에 잘 정리된 배치는 집중도 높은 비즈니스 및 생산적인 코딩 시간을 보여줍니다.',
        tags: ['노트북', '코딩', '개발자', '커피', '다이어리', '사무실', '데스크테리어', '생산성', '작업공간'],
        dateAdded: DateTime.now().subtract(const Duration(minutes: 2)),
        isSample: true,
      ),
      GalleryImage(
        id: 'sample_mountain',
        imagePath: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&auto=format&fit=crop',
        caption: '이른 아침 자욱한 안개와 운무가 낮게 깔린 산맥 뒤로 붉고 웅장한 태양이 떠오르는 풍경입니다. 하늘은 보랏빛과 오렌지빛 그라데이션으로 화려하게 물들고 있으며, 실루엣으로 처리된 산봉우리들이 첩첩산중 겹쳐 있어 신비롭고 장엄한 대자연의 경외감을 선사합니다.',
        tags: ['산', '안개', '일출', '태양', '대자연', '보랏빛하늘', '운무', '풍경', '장엄함'],
        dateAdded: DateTime.now().subtract(const Duration(minutes: 1)),
        isSample: true,
      ),
    ];

    for (final sample in samples) {
      // Avoid duplication
      if (!_images.any((img) => img.id == sample.id)) {
        _images.insert(0, sample);
      }
    }

    await _saveImages();
    _isLoading = false;
    
    // Clear search so the newly added samples display immediately
    if (_isSearching) {
      search(_searchQuery);
    } else {
      notifyListeners();
    }
  }

  // Queue up images for background processing
  Future<void> addImagesToQueue(List<XFile> pickedFiles) async {
    if (pickedFiles.isEmpty) return;

    final appDir = await getApplicationDocumentsDirectory();
    final List<GalleryImage> newPlaceholders = [];

    for (final pickedFile in pickedFiles) {
      try {
        // Copy picked file to permanent App Documents folder to prevent file loss
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(pickedFile.path)}';
        final savedFile = await File(pickedFile.path).copy(path.join(appDir.path, fileName));

        final placeholder = GalleryImage(
          id: DateTime.now().microsecondsSinceEpoch.toString() + newPlaceholders.length.toString(),
          imagePath: savedFile.path,
          caption: '[대기 중] 백그라운드 AI 분석 대기 중...',
          tags: ['대기중'],
          dateAdded: DateTime.now(),
          isPending: true,
        );

        newPlaceholders.add(placeholder);
      } catch (e) {
        print('Error copying picked file: $e');
      }
    }

    if (newPlaceholders.isNotEmpty) {
      // Add placeholders to our main list at the beginning (latest first)
      for (final img in newPlaceholders.reversed) {
        _images.insert(0, img);
      }
      await _saveImages();
      
      // Enqueue to background process list
      _backgroundQueue.addAll(newPlaceholders);
      notifyListeners();
      
      // Start processing queue
      _processBackgroundQueue();
    }
  }

  // Process the queue one-by-one simulating an offline background service
  Future<void> _processBackgroundQueue() async {
    if (_isBackgroundWorkerRunning) return;
    _isBackgroundWorkerRunning = true;
    notifyListeners();

    while (_backgroundQueue.isNotEmpty) {
      final target = _backgroundQueue.first;
      
      // Update image status to "Analyzing" in UI
      final index = _images.indexWhere((img) => img.id == target.id);
      if (index != -1) {
        _images[index] = _images[index].copyWith(
          caption: '⚡ [분석 중] Gemma 4 Vision 모델이 이미지 구성 요소를 파악하고 있습니다...',
          tags: ['분석중...'],
        );
        notifyListeners();
      }

      // Simulate on-device neural net load delay for beautiful visual feedback
      await Future.delayed(const Duration(seconds: 2));

      try {
        final imgFile = File(target.imagePath);
        if (await imgFile.exists()) {
          final bytes = await imgFile.readAsBytes();
          
          // Determine MIME Type
          String mimeType = 'image/jpeg';
          if (target.imagePath.toLowerCase().endsWith('.png')) {
            mimeType = 'image/png';
          } else if (target.imagePath.toLowerCase().endsWith('.webp')) {
            mimeType = 'image/webp';
          }

          // Call service
          final result = await _aiService.generateCaption(bytes, mimeType);

          // Update image model with final caption and tags
          final freshIndex = _images.indexWhere((img) => img.id == target.id);
          if (freshIndex != -1) {
            _images[freshIndex] = _images[freshIndex].copyWith(
              caption: result['caption'] ?? '이미지 묘사를 작성하지 못했습니다.',
              tags: List<String>.from(result['tags'] ?? []),
              isPending: false,
            );
          }
        }
      } catch (e) {
        print('Error processing image in background queue: $e');
        // Handle failure by marking as failed/mock fallback
        final freshIndex = _images.indexWhere((img) => img.id == target.id);
        if (freshIndex != -1) {
          _images[freshIndex] = _images[freshIndex].copyWith(
            caption: '분석 중 에러가 발생했습니다. 로컬 기본 묘사를 불러옵니다.',
            tags: ['에러', '미완료'],
            isPending: false,
          );
        }
      }

      // Remove from queue and save state
      _backgroundQueue.removeAt(0);
      await _saveImages();
      
      // Update search results if we are currently searching
      if (_isSearching) {
        search(_searchQuery);
      } else {
        notifyListeners();
      }
    }

    _isBackgroundWorkerRunning = false;
    notifyListeners();
  }

  // Re-generate a caption for a specific image
  Future<void> reanalyzeImage(String id) async {
    final index = _images.indexWhere((img) => img.id == id);
    if (index == -1) return;

    final image = _images[index];
    _images[index] = image.copyWith(
      caption: '⚡ [다시 분석 중] AI 캡션 엔진을 재가동 중입니다...',
      tags: ['재분석중'],
      isPending: true,
    );
    notifyListeners();

    try {
      if (image.isSample) {
        // Simulate sample delay
        await Future.delayed(const Duration(seconds: 1));
        final result = await _aiService.generateCaption([], '', sampleUrl: image.imagePath);
        _images[index] = _images[index].copyWith(
          caption: result['caption'] ?? '',
          tags: List<String>.from(result['tags'] ?? []),
          isPending: false,
        );
      } else {
        final imgFile = File(image.imagePath);
        if (await imgFile.exists()) {
          final bytes = await imgFile.readAsBytes();
          String mimeType = image.imagePath.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
          final result = await _aiService.generateCaption(bytes, mimeType);
          _images[index] = _images[index].copyWith(
            caption: result['caption'] ?? '',
            tags: List<String>.from(result['tags'] ?? []),
            isPending: false,
          );
        }
      }
    } catch (e) {
      print('Error re-analyzing image: $e');
      _images[index] = _images[index].copyWith(
        isPending: false,
      );
    }

    await _saveImages();
    if (_isSearching) {
      search(_searchQuery);
    } else {
      notifyListeners();
    }
  }

  // Edit caption manually
  Future<void> updateCaptionManually(String id, String newCaption, List<String> newTags) async {
    final index = _images.indexWhere((img) => img.id == id);
    if (index == -1) return;

    _images[index] = _images[index].copyWith(
      caption: newCaption,
      tags: newTags,
    );

    await _saveImages();
    if (_isSearching) {
      search(_searchQuery);
    } else {
      notifyListeners();
    }
  }

  // Delete image from list and file system if it's not a sample URL
  Future<void> deleteImage(String id) async {
    final index = _images.indexWhere((img) => img.id == id);
    if (index == -1) return;

    final target = _images[index];
    if (!target.isSample) {
      try {
        final file = File(target.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting file: $e');
      }
    }

    _images.removeAt(index);
    _backgroundQueue.removeWhere((img) => img.id == id);
    await _saveImages();

    if (_isSearching) {
      search(_searchQuery);
    } else {
      notifyListeners();
    }
  }

  // Clear all images
  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    // Delete files
    for (final img in _images) {
      if (!img.isSample) {
        try {
          final file = File(img.imagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error clearing file: $e');
        }
      }
    }

    _images.clear();
    _searchResults.clear();
    _backgroundQueue.clear();
    _isSearching = false;
    _searchQuery = '';
    _isBackgroundWorkerRunning = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyImagesList);

    _isLoading = false;
    notifyListeners();
  }

  // Custom Search Query Engine (Cosine-like scoring)
  void search(String query) {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _isSearching = false;
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchResults.clear();

    final queryTerms = _searchQuery.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    if (queryTerms.isEmpty) {
      _isSearching = false;
      notifyListeners();
      return;
    }

    final List<GalleryImage> scoredList = [];

    for (final img in _images) {
      double score = 0.0;
      int matchedCount = 0;

      for (final term in queryTerms) {
        bool termMatched = false;

        // 1. Tag matches (highly weighted)
        for (final tag in img.tags) {
          final tagLower = tag.toLowerCase();
          if (tagLower == term) {
            score += 0.5;
            termMatched = true;
          } else if (tagLower.contains(term)) {
            score += 0.25;
            termMatched = true;
          }
        }

        // 2. Caption matches
        final captionLower = img.caption.toLowerCase();
        if (captionLower.contains(term)) {
          score += 0.3;
          termMatched = true;
        }

        if (termMatched) {
          matchedCount++;
        }
      }

      if (matchedCount > 0) {
        double finalScore = score / queryTerms.length;
        if (finalScore > 1.0) finalScore = 1.0;
        
        // Match term penalty: if search is "바다 강아지" and image matches only "바다", scale it down
        finalScore = finalScore * (matchedCount / queryTerms.length);

        scoredList.add(img.copyWith(searchScore: finalScore));
      }
    }

    // Sort by searchScore descending (highest match percentage first)
    scoredList.sort((a, b) => b.searchScore.compareTo(a.searchScore));
    _searchResults.addAll(scoredList);
    notifyListeners();
  }
}
