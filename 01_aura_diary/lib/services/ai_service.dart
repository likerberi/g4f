import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

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

  // Generate Sentiment analysis prompt
  String _buildPrompt(String diaryContent) {
    return '''
사용자가 작성한 아래의 일기 내용을 깊이 분석하여 정서적 피드백을 제공해 주세요.
반드시 아래 정의된 JSON 형식으로만 응답해야 하며, 어떠한 마크다운 백틱(```json)도 사용하지 말고 순수 JSON 문자열만 출력해야 합니다.

JSON schema:
{
  "sentiment": "감정 단어 (기쁨, 슬픔, 분노, 평온, 설렘 중 하나 선택)",
  "sentimentColorHex": "해당 감정에 매우 잘 어울리는 화사하고 세련된 파스텔톤 컬러 Hex 코드 (예: 기쁨은 #FFD8A8, 평온은 #D0EBFF, 슬픔은 #E5DBFF 등)",
  "replyText": "일기 내용에 대해 진심어린 공감과 따뜻한 감동을 주는 3~4문장의 존댓말 답장",
  "advice": "오늘 하루를 보완하거나 내일의 긍정적인 마음가짐을 돕는 가벼운 행동 팁 1가지 제시"
}

사용자 일기 내용:
"$diaryContent"
''';
  }

  // Analyze diary entry
  Future<DiaryEntry> analyzeDiary(String content) async {
    final config = await getConfig();
    final mode = config['mode'];
    final apiKey = config['apiKey'] ?? '';
    final ollamaUrl = config['ollamaUrl'] ?? defaultOllamaUrl;
    final ollamaModel = config['ollamaModel'] ?? defaultOllamaModel;

    final prompt = _buildPrompt(content);
    String rawResponse = '';

    try {
      if (mode == 'google' && apiKey.isNotEmpty) {
        // 1. Google AI SDK Call
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
        // 2. Ollama Local Endpoint Call
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
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          rawResponse = decoded['response'] ?? '';
        } else {
          throw Exception('Ollama API error: ${response.statusCode}');
        }
      } else {
        // Mode is Google but API Key is empty -> fallback to mock immediately
        return _generateMockEntry(content);
      }

      // Parse JSON from response
      rawResponse = _cleanJson(rawResponse);
      final Map<String, dynamic> jsonMap = jsonDecode(rawResponse);

      return DiaryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        date: DateTime.now(),
        sentiment: jsonMap['sentiment'] ?? '평온',
        sentimentColorHex: jsonMap['sentimentColorHex'] ?? '#8E9AAF',
        replyText: jsonMap['replyText'] ?? '오늘 하루도 소중히 보내셨군요.',
        advice: jsonMap['advice'] ?? '차분히 심호흡을 하며 하루를 훌륭히 마쳐보세요.',
      );
    } catch (e) {
      print('AI Service Error: $e');
      // If error occurs, return a beautiful fallback mock entry so the app keeps working gracefully
      return _generateMockEntry(content);
    }
  }

  // Clean JSON response (strip markdown fences if models output them despite guidelines)
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

  // Mock reply generator for demo purposes when offline/no API key
  DiaryEntry _generateMockEntry(String content) {
    // Basic heuristics to determine mock sentiment
    String sentiment = '평온';
    String color = '#D0EBFF'; // soft blue
    String reply = '당신의 담담하고 평온한 하루를 읽으며 제 마음도 함께 차분해집니다. 특별한 굴곡 없이 물 흐르듯 흘러간 오늘 하루가 당신에게 소중한 쉼표가 되었기를 바랍니다. 수고 많으셨어요.';
    String advice = '잠들기 전, 따뜻한 물 한 잔을 마시며 편안한 음악을 들어보시는 건 어떨까요?';

    if (content.contains('슬프') || content.contains('힘들') || content.contains('우울') || content.contains('지쳐')) {
      sentiment = '슬픔';
      color = '#E5DBFF'; // soft violet
      reply = '일기를 쓰는 당신의 한 글자 한 글자에서 오늘 하루가 얼마나 고단하고 버거웠는지 깊이 전해집니다. 마음껏 울지 못해 답답했던 마음을 이렇게 털어놓아 주셔서 다행이에요. 지금 이 힘든 감정도 결국 지나갈 한 조각 바람일 뿐입니다. 마음속 짐을 잠시 내려놓으세요.';
      advice = '오늘 밤만큼은 자신을 위한 따뜻한 위로의 샤워와 함께 좋아하는 영화나 영상을 시청해 보세요.';
    } else if (content.contains('기쁘') || content.contains('좋아') || content.contains('신나') || content.contains('행복')) {
      sentiment = '기쁨';
      color = '#FFD8A8'; // soft orange/yellow
      reply = '와! 일기 속에 가득 피어난 행복한 미소가 저에게까지 그대로 전달되는 느낌입니다. 소소하고 뜻깊은 기쁨의 조각들이 당신의 마음속에 가득 쌓였네요. 이런 긍정적인 감정을 기록으로 남겨두면, 나중에 큰 힘이 되는 보물이 될 것입니다. 기쁜 소식 감사해요!';
      advice = '이 행복한 기운을 오랫동안 간직할 수 있게 소중한 사람에게 짧은 감사 안부 문자를 한 통 보내보세요.';
    } else if (content.contains('화나') || content.contains('짜증') || content.contains('열받') || content.contains('싸웠')) {
      sentiment = '분노';
      color = '#FFC9C9'; // soft red
      reply = '오늘 정말 화나고 속상한 일이 있으셨군요. 감정을 꾹꾹 눌러 담아 참기보다 이렇게 글로 풀어내 주신 것은 감정 조절에 매우 훌륭한 선택이었습니다. 일어난 일들은 속상하지만 마음껏 분출하시고, 상처받은 감정의 온도가 조금 내려가기를 진심으로 바랄게요.';
      advice = '주먹을 가볍게 쥐었다 펴며 긴장을 풀고, 5초 동안 천천히 숨을 들이쉬고 내쉬는 복식 호흡을 3회 반복해 보세요.';
    } else if (content.contains('설레') || content.contains('기대') || content.contains('시작') || content.contains('두근')) {
      sentiment = '설렘';
      color = '#FFF3BF'; // soft gold yellow
      reply = '가슴속에서 콩닥콩닥 피어오르는 기분 좋은 두근거림이 고스란히 느껴집니다. 새로운 시작이나 소중한 만남을 앞두고 계신가 봐요! 이 기분 좋은 긴장감과 설렘이 다가올 앞날에 밝은 빛을 비춰주기를 온 마음으로 응원하겠습니다. 화이팅이에요!';
      advice = '설레는 마음을 담아 다가올 특별한 날의 의상이나 작은 메모를 미리 차근차근 준비해보는 것도 좋습니다.';
    }

    return DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      date: DateTime.now(),
      sentiment: sentiment,
      sentimentColorHex: color,
      replyText: reply,
      advice: advice,
    );
  }
}
