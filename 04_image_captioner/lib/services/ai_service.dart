import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiService {
  static const String keyMode = 'ai_mode'; // 'google', 'ollama', or 'mock'
  static const String keyApiKey = 'google_api_key';
  static const String keyOllamaUrl = 'ollama_url';
  static const String keyOllamaModel = 'ollama_model';

  // Default values
  static const String defaultOllamaUrl = 'http://localhost:11434';
  static const String defaultOllamaModel = 'llava';

  // Singleton instance
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

  // Load configuration
  Future<Map<String, String>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mode': prefs.getString(keyMode) ?? 'mock',
      'apiKey': prefs.getString(keyApiKey) ?? '',
      'ollamaUrl': prefs.getString(keyOllamaUrl) ?? defaultOllamaUrl,
      'ollamaModel': prefs.getString(keyOllamaModel) ?? defaultOllamaModel,
    };
  }

  // Generate prompt
  String _buildPrompt() {
    return '이 이미지의 구도, 피사체, 색상, 분위기, 행동 등을 한국어로 상세히 분석하여 묘사해 주세요. 그리고 설명의 마지막 줄에 이미지와 관련된 키워드 태그들을 "태그: 태그1, 태그2, 태그3"과 같은 형식으로 5~8개 적어주세요. 이미지 설명과 태그는 반드시 한국어로 작성해 주세요.';
  }

  // Preset sample image captions and tags for offline/demo simulation
  static final Map<String, Map<String, dynamic>> _samplePresets = {
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop': {
      'caption': '눈부시게 맑고 화창한 날, 드넓게 펼쳐진 황금빛 백사장과 에메랄드빛 바다가 어우러진 해변 풍경입니다. 하얀 거품을 일으키며 부드럽게 밀려오는 파도가 인상적이며, 하늘에는 구름 한 점 없이 투명한 파란색을 띠고 있습니다. 평화롭고 따뜻한 여름날의 휴양지 감성이 고스란히 담겨 있어 보는 것만으로도 힐링되는 사진입니다.',
      'tags': ['바다', '해변', '백사장', '파도', '파란하늘', '휴양지', '여름', '힐링', '풍경'],
    },
    'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800&auto=format&fit=crop': {
      'caption': '싱그러운 초록빛 잔디밭 위에 엎드려 카메라를 향해 혀를 살짝 내밀고 해맑게 웃고 있는 귀여운 골든 리트리버 강아지입니다. 복슬복슬한 황금빛 털이 햇살을 받아 반짝이고 있으며, 호기심 어린 눈망울과 처진 귀가 매력적입니다. 반려동물의 행복하고 평화로운 일상을 따뜻하게 포착해낸 사진입니다.',
      'tags': ['강아지', '골든리트리버', '반려동물', '잔디밭', '동물', '귀여움', '미소', '햇살', '일상'],
    },
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800&auto=format&fit=crop': {
      'caption': '울창하고 깊은 숲속을 가로지르는 고요한 흙길 산책로입니다. 길 주변으로는 키가 큰 나무들이 빽빽하게 우거져 있으며, 나뭇잎 사이로 따스한 아침 햇살이 갈라져 내려와 숲 바닥을 부드럽게 비추고 있습니다. 자연의 싱그러운 초록색 에너지가 느껴지며, 고요하고 평화로운 피톤치드 가득한 아침 산책의 정취를 자아냅니다.',
      'tags': ['숲', '산책로', '나무', '햇살', '초록빛', '자연', '피톤치드', '아침', '고요함', '풍경'],
    },
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&auto=format&fit=crop': {
      'caption': '현대적이고 깔끔하게 정리된 개발자의 작업 공간입니다. 검은색 화면 위에 하이라이트된 소스코드가 적혀 있는 노트북이 열려 있고, 옆에는 따뜻한 검은색 커피가 담긴 머그잔, 가죽 다이어리, 그리고 하얀 펜이 놓여 있습니다. 세련된 그레이 톤의 책상 위에 잘 정리된 배치는 집중도 높은 비즈니스 및 생산적인 코딩 시간을 보여줍니다.',
      'tags': ['노트북', '코딩', '개발자', '커피', '다이어리', '사무실', '데스크테리어', '생산성', '작업공간'],
    },
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&auto=format&fit=crop': {
      'caption': '이른 아침 자욱한 안개와 운무가 낮게 깔린 산맥 뒤로 붉고 웅장한 태양이 떠오르는 풍경입니다. 하늘은 보랏빛과 오렌지빛 그라데이션으로 화려하게 물들고 있으며, 실루엣으로 처리된 산봉우리들이 첩첩산중 겹쳐 있어 신비롭고 장엄한 대자연의 경외감을 선사합니다.',
      'tags': ['산', '안개', '일출', '태양', '대자연', '보랏빛하늘', '운무', '풍경', '장엄함'],
    },
  };

  // Caption analysis
  Future<Map<String, dynamic>> generateCaption(List<int> imageBytes, String mimeType, {String? sampleUrl}) async {
    // 1. If it's a sample URL and exists in our presets, return immediately for crisp simulation
    if (sampleUrl != null && _samplePresets.containsKey(sampleUrl)) {
      return _samplePresets[sampleUrl]!;
    }

    final config = await getConfig();
    final mode = config['mode'];
    final apiKey = config['apiKey'] ?? '';
    final ollamaUrl = config['ollamaUrl'] ?? defaultOllamaUrl;
    final ollamaModel = config['ollamaModel'] ?? defaultOllamaModel;

    final prompt = _buildPrompt();
    String rawResponse = '';

    try {
      if (mode == 'google' && apiKey.isNotEmpty) {
        // Google GenAI Vision Call (Gemini 1.5 Flash)
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        final content = [
          Content.multi([
            TextPart(prompt),
            DataPart(mimeType, Uint8List.fromList(imageBytes)),
          ])
        ];
        final response = await model.generateContent(content);
        rawResponse = response.text ?? '';
      } else if (mode == 'ollama') {
        // Ollama Local Vision Call (e.g. llava, paligemma)
        final cleanUrl = ollamaUrl.endsWith('/') ? ollamaUrl.substring(0, ollamaUrl.length - 1) : ollamaUrl;
        final base64Image = base64Encode(imageBytes);

        final response = await http.post(
          Uri.parse('$cleanUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': ollamaModel,
            'prompt': prompt,
            'images': [base64Image],
            'stream': false,
          }),
        ).timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          rawResponse = decoded['response'] ?? '';
        } else {
          throw Exception('Ollama Vision API error: ${response.statusCode}');
        }
      } else {
        // Fallback or explicit Mock mode
        return _generateMockCaption(imageBytes);
      }

      // Parse the response to extract tags and main description
      return _parseResponse(rawResponse);
    } catch (e) {
      print('AI Vision Service Error: $e');
      return _generateMockCaption(imageBytes);
    }
  }

  // Helper to parse description and tags out of raw text response
  Map<String, dynamic> _parseResponse(String rawText) {
    String caption = rawText.trim();
    List<String> tags = [];

    // Search for tags line: e.g. "태그: 바다, 해변, 백사장" or "TAGS: beach, sea"
    final tagRegex = RegExp(r'(?:태그|태그들|TAGS|Tags)\s*:\s*(.*)', caseSensitive: false);
    final match = tagRegex.firstMatch(caption);

    if (match != null) {
      final tagLine = match.group(1) ?? '';
      // Remove the tag line from the caption
      caption = caption.replaceRange(match.start, match.end, '').trim();

      // Parse tags
      tags = tagLine
          .split(RegExp(r'[,#]'))
          .map((t) => t.trim().replaceAll('#', ''))
          .where((t) => t.isNotEmpty)
          .toList();
    } else {
      // Back up: try to find simple commas at the very end
      final lines = caption.split('\n');
      if (lines.isNotEmpty && lines.last.contains(',') && lines.last.length < 100) {
        final lastLine = lines.last;
        tags = lastLine
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        caption = lines.sublist(0, lines.length - 1).join('\n').trim();
      }
    }

    // If no tags were found, extract keywords from the description
    if (tags.isEmpty) {
      tags = _extractKeywords(caption);
    }

    // Limit tags to 8 maximum
    if (tags.length > 8) {
      tags = tags.sublist(0, 8);
    }

    return {
      'caption': caption,
      'tags': tags,
    };
  }

  // Simple keyword extractor
  List<String> _extractKeywords(String text) {
    final words = text
        .replaceAll(RegExp(r'[^a-zA-Z0-9가-힣]+'), ' ')
        .split(' ')
        .map((w) => w.trim())
        .where((w) => w.length >= 2 && !w.contains(RegExp(r'[0-9]')))
        .toList();

    // Take unique words
    final unique = words.toSet().toList();
    final defaultKeywords = ['갤러리', '사진', '이미지', '분석', '로컬', '스마트'];
    final list = unique.take(5).toList();
    while (list.length < 4 && defaultKeywords.isNotEmpty) {
      final kw = defaultKeywords.removeAt(0);
      if (!list.contains(kw)) list.add(kw);
    }
    return list;
  }

  // Dynamic mock generator for arbitrary custom uploaded images
  Map<String, dynamic> _generateMockCaption(List<int> imageBytes) {
    final length = imageBytes.length;
    final timeString = DateTime.now().toLocal().toString().substring(11, 16);
    
    // Create somewhat dynamic captions based on byte sizes so different images look different!
    String caption = '';
    List<String> tags = [];

    if (length % 3 == 0) {
      caption = '따뜻하고 부드러운 전구색 조명이 비추는 아늑한 실내 분위기의 공간입니다. 가구와 인테리어 소품들이 빈티지하면서도 세련된 배치를 이루고 있으며, 전반적으로 아늑하고 정겨운 아날로그 감성이 흐릅니다. 차 한 잔의 여유를 즐기기에 좋은 공간 묘사입니다.';
      tags = ['실내', '인테리어', '아늑함', '조명', '빈티지', '감성', '따뜻함'];
    } else if (length % 3 == 1) {
      caption = '탁 트인 개방감을 보여주는 세련된 도심 속 야외 거리입니다. 높은 빌딩들이 줄지어 늘어서 있으며, 역동적인 도시의 에너지를 품고 있습니다. 맑고 청량한 파란 하늘 아래에서 지나가는 사람들의 활기참과 바쁜 일상이 조화롭게 녹아 있습니다.';
      tags = ['도시', '빌딩', '거리', '풍경', '하늘', '활기찬', '야외', '도심'];
    } else {
      caption = '다양한 소품과 흥미로운 구성 요소들이 복합적으로 배치된 일상적인 오브젝트 촬영 사진입니다. 독특한 질감과 색채 대비가 두드러지며, 조화로운 구도로 포착되어 시각적 흥미를 자극합니다. 정물적 매력과 디자인 감각이 묻어나는 구도입니다.';
      tags = ['오브젝트', '디자인', '정물', '일상', '색채', '질감', '클로즈업'];
    }

    return {
      'caption': '[$timeString 분석 완료] $caption\n\n(참고: 현재 오프라인 모크 시뮬레이션 상태이므로 임시 생성된 묘사입니다. 설정에서 Google AI Studio API 키 또는 Ollama를 활성화하면 실제 스마트 비전 분석을 제공합니다.)',
      'tags': tags,
    };
  }
}
