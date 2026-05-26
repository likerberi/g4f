import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event.dart';

class AiService {
  static const String keyMode = 'ai_mode'; // 'google' or 'ollama'
  static const String keyApiKey = 'google_api_key';
  static const String keyOllamaUrl = 'ollama_url';
  static const String keyOllamaModel = 'ollama_model';

  // Default values
  static const String defaultOllamaUrl = 'http://localhost:11434';
  static const String defaultOllamaModel = 'gemma4:e2b';

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
      'mode': prefs.getString(keyMode) ?? 'google',
      'apiKey': prefs.getString(keyApiKey) ?? '',
      'ollamaUrl': prefs.getString(keyOllamaUrl) ?? defaultOllamaUrl,
      'ollamaModel': prefs.getString(keyOllamaModel) ?? defaultOllamaModel,
    };
  }

  // Generate Prompt with Dynamic Anchor Date (System Date)
  String _buildPrompt(String input, DateTime now) {
    final daysOfWeek = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final todayDayOfWeek = daysOfWeek[now.weekday % 7];

    return '''
사용자가 자연어로 입력한 일정 추가 요청 문장에서 제목(title), 날짜(date), 시간(time), 장소(location)를 정밀하게 추출하여 JSON 형식으로 파싱해야 합니다.
반드시 아래 정의된 JSON 형식으로만 응답해야 하며, 어떠한 마크다운 백틱(```json)도 사용하지 말고 순수 JSON 문자열만 출력해야 합니다.

중요: 아래의 기준 날짜(Anchor Date)를 참고하여 "오늘", "내일", "다음주 목요일" 등의 상대적인 표현을 정확한 연/월/일 포맷(YYYY-MM-DD)으로 계산하십시오.
- **기준 날짜(Anchor Date)**: $todayStr ($todayDayOfWeek)

JSON schema:
{
  "title": "추출된 일정 제목 (예: 팀 정기 미팅, 영어 과외, 친구 생일 파티)",
  "date": "추출된 날짜 (YYYY-MM-DD 형식, 반드시 기준 날짜를 기반으로 계산)",
  "time": "추출된 시간 (HH:MM 24시간 형식, 추출 불가시 12:00)",
  "location": "추출된 장소 (예: 강남역 스타벅스, 3층 대회의실, 미기재 시 빈 문자열)"
}

입력 텍스트:
"$input"
''';
  }

  // Extract Event using AI or Fallback
  Future<CalendarEvent> parseEvent(String inputText) async {
    final now = DateTime.now();
    final config = await getConfig();
    final mode = config['mode'];
    final apiKey = config['apiKey'] ?? '';
    final ollamaUrl = config['ollamaUrl'] ?? defaultOllamaUrl;
    final ollamaModel = config['ollamaModel'] ?? defaultOllamaModel;

    final prompt = _buildPrompt(inputText, now);
    String rawResponse = '';

    try {
      if (mode == 'google' && apiKey.isNotEmpty) {
        // 1. Google AI Studio SDK call
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
        // 2. Ollama Local Endpoint call
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
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          rawResponse = decoded['response'] ?? '';
        } else {
          throw Exception('Ollama API error: ${response.statusCode}');
        }
      } else {
        // API key is empty or offline fallback
        return _generateMockEvent(inputText, now);
      }

      // Parse JSON from response
      rawResponse = _cleanJson(rawResponse);
      final Map<String, dynamic> jsonMap = jsonDecode(rawResponse);

      final extractedTitle = jsonMap['title'] ?? '';
      final extractedDateStr = jsonMap['date'] ?? '';
      final extractedTime = jsonMap['time'] ?? '12:00';
      final extractedLocation = jsonMap['location'] ?? '';

      // Validate date
      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(extractedDateStr);
      } catch (_) {
        parsedDate = now;
      }

      return CalendarEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: extractedTitle.isNotEmpty ? extractedTitle : '새로운 일정',
        date: parsedDate,
        time: extractedTime,
        location: extractedLocation,
        originalText: inputText,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('AI Parsing Error: $e. Falling back to Mock NLP Engine.');
      return _generateMockEvent(inputText, now);
    }
  }

  // Clean Markdown response formatting
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

  // Sophisticated Mock NLP Engine for Korean relative time & keyword extraction
  CalendarEvent _generateMockEvent(String text, DateTime now) {
    String title = '';
    DateTime date = now;
    String time = '12:00';
    String location = '';

    final cleanedText = text.trim();

    // 1. Resolve Location (Look for keywords preceding "에서" or specific spots)
    final fromIndex = cleanedText.indexOf('에서');
    if (fromIndex != -1) {
      // Find starting point of location (usually preceded by space)
      final preFromText = cleanedText.substring(0, fromIndex);
      final words = preFromText.split(' ');
      if (words.isNotEmpty) {
        location = words.last;
      }
    } else {
      // Try specific locations
      final locations = ['강남역', '홍대입구역', '코엑스', '스타벅스', '신촌', '회사', '안방', '회의실', '헬스장', '학교', '카페', '사무실'];
      for (final loc in locations) {
        if (cleanedText.contains(loc)) {
          location = loc;
          break;
        }
      }
    }

    // 2. Resolve Relative Dates
    if (cleanedText.contains('오늘')) {
      date = now;
    } else if (cleanedText.contains('내일')) {
      date = now.add(const Duration(days: 1));
    } else if (cleanedText.contains('모레')) {
      date = now.add(const Duration(days: 2));
    } else if (cleanedText.contains('어제')) {
      date = now.subtract(const Duration(days: 1));
    } else {
      // Resolve day of week ("금요일", "다음주 목요일" etc.)
      final daysOfWeekKo = ['월', '화', '수', '목', '금', '토', '일'];
      int foundDayIndex = -1;
      for (int i = 0; i < daysOfWeekKo.length; i++) {
        if (cleanedText.contains('${daysOfWeekKo[i]}요일') || cleanedText.contains('${daysOfWeekKo[i]}요일에')) {
          foundDayIndex = i + 1; // 1 = Mon, 7 = Sun
          break;
        }
      }

      if (foundDayIndex != -1) {
        // Calculate days to add
        int currentDayOfWeek = now.weekday; // 1-7
        int daysToAdd = foundDayIndex - currentDayOfWeek;
        if (daysToAdd <= 0) {
          daysToAdd += 7; // next week's day
        }
        
        if (cleanedText.contains('다음주') || cleanedText.contains('다음 주')) {
          if (foundDayIndex <= currentDayOfWeek) {
            // Already added 7, keep it or adjust
          } else {
            daysToAdd += 7;
          }
        }
        date = now.add(Duration(days: daysToAdd));
      } else {
        // Try to parse exact date patterns: "5월 27일", "05/27", "2026-05-27"
        final regexMonthDay = RegExp(r'(\d{1,2})월\s*(\d{1,2})일');
        final match = regexMonthDay.firstMatch(cleanedText);
        if (match != null) {
          final m = int.parse(match.group(1)!);
          final d = int.parse(match.group(2)!);
          date = DateTime(now.year, m, d);
        }
      }
    }

    // 3. Resolve Times: e.g. "오후 3시", "아침 9시 반", "18:00", "7시"
    int hour = 12;
    int minute = 0;
    bool isPm = cleanedText.contains('오후') || cleanedText.contains('저녁') || cleanedText.contains('밤');
    bool isAm = cleanedText.contains('오전') || cleanedText.contains('아침') || cleanedText.contains('새벽');

    final regexTime = RegExp(r'(\d{1,2})\s*시\s*(\d{1,2})?분?');
    final matchTime = regexTime.firstMatch(cleanedText);
    if (matchTime != null) {
      hour = int.parse(matchTime.group(1)!);
      if (matchTime.group(2) != null) {
        minute = int.parse(matchTime.group(2)!);
      } else if (cleanedText.contains('$hour시 반') || cleanedText.contains('$hour시반')) {
        minute = 30;
      }
      
      if (isPm && hour < 12) {
        hour += 12;
      } else if (isAm && hour == 12) {
        hour = 0;
      }
    } else {
      // Look for HH:MM format
      final regexDigital = RegExp(r'(\d{2}):(\d{2})');
      final matchDigital = regexDigital.firstMatch(cleanedText);
      if (matchDigital != null) {
        hour = int.parse(matchDigital.group(1)!);
        minute = int.parse(matchDigital.group(2)!);
      }
    }
    time = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";

    // 4. Resolve Title (Extract preceding words of action: "미팅", "약속", "식사", "회의", "스터디", "피티", "레슨")
    final actionKeywords = ['미팅', '약속', '식사', '회의', '스터디', '피티', '레슨', '생신', '생일', '운동', '과외', '세미나', '워크숍', '교육', '데이트'];
    for (final kw in actionKeywords) {
      if (cleanedText.contains(kw)) {
        // Look for words preceding this keyword
        final index = cleanedText.indexOf(kw);
        final preceding = cleanedText.substring(0, index + kw.length);
        // Clean preceding text from time and date keywords
        var cleanTitle = preceding
            .replaceAll(RegExp(r'(오늘|내일|모레|어제|다음주|다음 주)'), '')
            .replaceAll(RegExp(r'\d{1,2}월\s*\d{1,2}일'), '')
            .replaceAll(RegExp(r'(월요일|화요일|수요일|목요일|금요일|토요일|일요일)'), '')
            .replaceAll(RegExp(r'(오전|오후|아침|저녁|밤|새벽)\s*\d{1,2}시(\s*\d{1,2}분)?(\s*반)?'), '')
            .replaceAll(RegExp(r'\d{1,2}시\s*(\d{1,2}분)?(\s*반)?'), '')
            .replaceAll(RegExp(r'\d{2}:\d{2}'), '')
            .replaceAll(location, '')
            .replaceAll('에서', '')
            .replaceAll('에 ', '')
            .trim();

        if (cleanTitle.startsWith('가 ') || cleanTitle.startsWith('이 ')) {
          cleanTitle = cleanTitle.substring(2);
        }
        
        if (cleanTitle.isNotEmpty) {
          title = cleanTitle;
        } else {
          title = '$kw 일정';
        }
        break;
      }
    }

    if (title.isEmpty) {
      // Fallback title: clean up the whole text and make it the title
      var cleanTitle = cleanedText
          .replaceAll(RegExp(r'(오늘|내일|모레|어제|다음주|다음 주)'), '')
          .replaceAll(RegExp(r'(월요일|화요일|수요일|목요일|금요일|토요일|일요일)'), '')
          .replaceAll(RegExp(r'(오전|오후|아침|저녁|밤|새벽)\s*\d{1,2}시(\s*\d{1,2}분)?(\s*반)?'), '')
          .replaceAll(RegExp(r'\d{1,2}시\s*(\d{1,2}분)?(\s*반)?'), '')
          .replaceAll(RegExp(r'\d{2}:\d{2}'), '')
          .replaceAll('에서', '')
          .trim();
      if (location.isNotEmpty) {
        cleanTitle = cleanTitle.replaceAll(location, '').trim();
      }
      title = cleanTitle.isNotEmpty ? cleanTitle : '자연어 추출 일정';
    }

    return CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: DateTime(date.year, date.month, date.day),
      time: time,
      location: location,
      originalText: text,
      createdAt: DateTime.now(),
    );
  }
}
