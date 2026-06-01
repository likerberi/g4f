import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/tutor_character.dart';

class AiService {
  static const String keyMode = 'ai_mode'; // 'google' or 'ollama'
  static const String keyApiKey = 'google_api_key';
  static const String keyOllamaUrl = 'ollama_url';
  static const String keyOllamaModel = 'ollama_model';

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

  // Build the detailed system instructions for the LLM
  String _buildSystemPrompt(TutorCharacter character) {
    return '''
당신은 영어 회화 학습을 도와주는 1:1 개인 튜터입니다.
다음 인물의 정체성, 말투(Tone and Manner)를 완전히 모사하여 응답하십시오:
- **이름**: ${character.name}
- **역할**: ${character.role}
- **특징 및 톤앤매너**: ${character.systemPrompt}

[응답 규칙]
반드시 아래 JSON 스키마 형식의 유효한 JSON 문자열로만 응답하십시오.
어떠한 마크다운 백틱(```json ... ```)이나 서론, 결론 없이 오직 순수한 JSON 데이터만 응답해야 합니다.

{
  "corrected": "사용자가 입력한 영어 문장에 문법 오류, 부적절한 표현, 어색한 어휘가 있다면 자연스러운 교정 문장을 작성하십시오. 오류가 전혀 없고 원어민처럼 자연스럽다면 반드시 null을 넣으십시오.",
  "explanation": "문법 오류가 발생하여 교정했을 경우, 왜 고쳐야 하는지 이유와 팁을 한국어(Korean)로 한두 문장으로 쉽고 친절하게 설명하십시오. 교정이 필요 없어 corrected가 null이라면 이 항목도 반드시 null로 하십시오.",
  "reply": "역할(Character)에 맞추어 사용자의 대화에 이어지는 리액션과 질문 등을 영어(English)로 대화식으로 작성하십시오. 친절하고 자연스러운 리액션이어야 합니다."
}
''';
  }

  // Orchestrate prompt and generate response
  Future<Map<String, dynamic>> generateResponse(TutorCharacter character, List<ChatMessage> history, String newUserText) async {
    final config = await getConfig();
    final mode = config['mode'];
    final apiKey = config['apiKey'] ?? '';
    final ollamaUrl = config['ollamaUrl'] ?? defaultOllamaUrl;
    final ollamaModel = config['ollamaModel'] ?? defaultOllamaModel;

    final systemPrompt = _buildSystemPrompt(character);
    
    // Format full conversation context
    String conversationHistory = "";
    // Only take the last 8 messages for token efficiency and memory windowing
    final recentHistory = history.length > 8 ? history.sublist(history.length - 8) : history;
    for (var msg in recentHistory) {
      final role = msg.sender == 'user' ? 'User' : character.name;
      conversationHistory += "$role: ${msg.text}\n";
    }
    conversationHistory += "User: $newUserText\n";

    final prompt = '''
$systemPrompt

[대화 흐름]
$conversationHistory
''';

    try {
      String rawResponse = '';

      if (mode == 'google' && apiKey.isNotEmpty) {
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
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          rawResponse = decoded['response'] ?? '';
        } else {
          throw Exception('Ollama server returned status ${response.statusCode}');
        }
      } else {
        // Fallback to offline Mock NLP Engine
        return _generateMockResponse(character, newUserText);
      }

      rawResponse = _cleanJson(rawResponse);
      final decodedMap = jsonDecode(rawResponse);
      return {
        'corrected': decodedMap['corrected'],
        'explanation': decodedMap['explanation'],
        'reply': decodedMap['reply'] ?? "I'm sorry, I couldn't process that properly.",
      };
    } catch (e) {
      print('AI Service Error: $e. Using local Mock Engine.');
      return _generateMockResponse(character, newUserText);
    }
  }

  // Trim and clean JSON formatting
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

  // Complex local simulator for grammar correction and conversation flow
  Map<String, dynamic> _generateMockResponse(TutorCharacter character, String input) {
    final cleanInput = input.trim().toLowerCase();
    String? corrected;
    String? explanation;
    String reply = "";

    // 1. Detect Common Korean English Errors
    if (RegExp(r'\bwant\s+to\s+\w+ing\b').hasMatch(cleanInput)) {
      // "want to ordering", "want to playing"
      final match = RegExp(r'\b(want\s+to\s+)(\w+)(ing)\b').firstMatch(cleanInput);
      if (match != null) {
        final verb = match.group(2);
        corrected = input.replaceAll(RegExp(r'\bwant\s+to\s+\w+ing\b', caseSensitive: false), 'want to $verb');
        explanation = "'want to' 뒤에는 동사원형이 옵니다. 동사뒤에 -ing를 붙이지 않고 'want to $verb'로 표현해 보세요!";
      }
    } else if (cleanInput.contains("i am agree") || cleanInput.contains("i'm agree")) {
      corrected = input.replaceAll(RegExp(r"\bi\s*(am|'m)\s*agree\b", caseSensitive: false), 'I agree');
      explanation = "'agree'는 자체로 동사이기 때문에 am/are 등의 비동사와 함께 쓰지 않습니다. 깔끔하게 'I agree'라고 말해 보세요.";
    } else if (RegExp(r"\b(she|he|it)\s+don't\b").hasMatch(cleanInput)) {
      corrected = input.replaceAll(RegExp(r"\bdon't\b", caseSensitive: false), "doesn't");
      explanation = "주어가 3인칭 단수(She/He/It)일 때 부정형은 don't가 아니라 doesn't를 써야 올바릅니다.";
    } else if (RegExp(r"\b(she|he|it)\s+(go|like|play|want)\b").hasMatch(cleanInput)) {
      // 3rd person singular present tense marker -s
      final match = RegExp(r"\b(she|he|it)\s+(go|like|play|want)\b").firstMatch(cleanInput);
      if (match != null) {
        final subject = match.group(1) ?? '';
        final verb = match.group(2) ?? '';
        String correctVerb = "${verb}s";
        if (verb == "go") correctVerb = "goes";
        corrected = input.replaceAll(RegExp(r"\b" + verb + r"\b", caseSensitive: false), correctVerb);
        explanation = "주어가 3인칭 단수($subject)이고 시제가 현재일 때는 동사 뒤에 -s/-es를 붙여 '$correctVerb'로 써야 합니다.";
      }
    } else if (cleanInput.contains("more better")) {
      corrected = input.replaceAll(RegExp(r"\bmore\s+better\b", caseSensitive: false), "much better");
      explanation = "'better'는 이미 'good'의 비교급이므로 앞에 'more'를 중복하여 쓰지 않습니다. 강조하려면 'much better'라고 씁니다.";
    } else if (cleanInput.contains("look forward to see")) {
      corrected = input.replaceAll(RegExp(r"\blook\s+forward\s+to\s+see\b", caseSensitive: false), "look forward to seeing");
      explanation = "'look forward to'의 'to'는 전치사이므로 뒤에 동사원형이 아닌 동명사형(seeing)이 와야 합니다.";
    } else if (cleanInput.contains("homeworks")) {
      corrected = input.replaceAll(RegExp(r"\bhomeworks\b", caseSensitive: false), "homework");
      explanation = "'homework'는 셀 수 없는 명사이므로 여러 개여도 뒤에 -s를 붙여 homeworks로 표현하지 않습니다.";
    } else if (cleanInput.contains("i am visit")) {
      corrected = input.replaceAll(RegExp(r"\bi\s*(am|'m)\s*visit\b", caseSensitive: false), "I visited");
      explanation = "과거에 어딘가에 방문했다는 사실을 표현할 때는 비동사 없이 간단하게 과거 동사형 'I visited' 또는 'I went to'라고 씁니다.";
    }

    // 2. Persona Specific Conversational Replies
    if (character.id == 'sophia') {
      // Sophia - Friendly Friend
      if (cleanInput.contains("hello") || cleanInput.contains("hi") || cleanInput.contains("hey")) {
        reply = "Hey! Great to see you! How is everything going with you today? Doing anything fun?";
      } else if (cleanInput.contains("food") || cleanInput.contains("eat") || cleanInput.contains("hungry") || cleanInput.contains("pizza") || cleanInput.contains("lunch") || cleanInput.contains("dinner")) {
        reply = "Oh my gosh, talking about food makes me so hungry! I had pizza yesterday and it was delicious. What is your absolute favorite food to eat when you want to treat yourself?";
      } else if (cleanInput.contains("hobby") || cleanInput.contains("fun") || cleanInput.contains("watch") || cleanInput.contains("music") || cleanInput.contains("movie")) {
        reply = "That sounds so fun! In my free time, I really love watching Netflix series or listening to cozy indie pop music. What kind of movies or music do you usually enjoy?";
      } else if (cleanInput.contains("weary") || cleanInput.contains("tired") || cleanInput.contains("hard") || cleanInput.contains("exhausted")) {
        reply = "Aw, I'm so sorry to hear that you are feeling tired. Life can be tough sometimes, but you are doing great! Make sure to get some good rest tonight, okay? Anything I can do to cheer you up?";
      } else {
        reply = "Oh, that is so interesting! I love hearing your thoughts on this. Can you tell me a little bit more about that? I'm all ears!";
      }
    } else if (character.id == 'liam') {
      // Liam - Business Coach
      if (cleanInput.contains("hello") || cleanInput.contains("hi") || cleanInput.contains("good morning") || cleanInput.contains("good afternoon")) {
        reply = "Good day to you. It is a pleasure to connect. Let us focus our efforts today on enhancing your professional communication skills. What specific agenda shall we discuss?";
      } else if (cleanInput.contains("job") || cleanInput.contains("interview") || cleanInput.contains("resume") || cleanInput.contains("work")) {
        reply = "Preparing for interviews requires structured articulation. A recommended approach is using the STAR method (Situation, Task, Action, Result). Could you try describing a challenging project you successfully delivered?";
      } else if (cleanInput.contains("presentation") || cleanInput.contains("meeting") || cleanInput.contains("report")) {
        reply = "When presenting, clarity and brevity are paramount. To keep your audience engaged, try to highlight the core impact immediately. Would you like to practice an opening statement for an upcoming presentation?";
      } else {
        reply = "I see. That is a valuable business perspective. In a professional setting, we might also phrase that as 'leveraging key insights'. How do you feel about applying this terminology to our dialogue?";
      }
    } else if (character.id == 'chloe') {
      // Chloe - Travel simulation
      if (cleanInput.contains("hotel") || cleanInput.contains("check in") || cleanInput.contains("booking") || cleanInput.contains("room")) {
        reply = "Perfect! *taps screen at the hotel front desk* 'Welcome to the Cosmic Grand Hotel. I see your reservation for a deluxe suite. May I please have your passport and credit card for verification?'";
      } else if (cleanInput.contains("coffee") || cleanInput.contains("order") || cleanInput.contains("starbucks") || cleanInput.contains("drink")) {
        reply = "Awesome! Let's do a cafe simulation. *stands behind the barista counter* 'Hi there! Welcome to Starbucks. What can I get started for you today? Any pastries with your espresso?'";
      } else if (cleanInput.contains("airport") || cleanInput.contains("custom") || cleanInput.contains("passport") || cleanInput.contains("visa")) {
        reply = "Got it! Let's simulate airport customs. *stamps passport strictly* 'Please state the primary purpose of your visit. Is it business or leisure? And how long do you intend to stay in the country?'";
      } else {
        reply = "That sounds like a wonderful travel plan! Travelling really broadens our horizons. What is the very first thing you want to do once we land at our destination?";
      }
    } else {
      // Oliver - IELTS Strict Examiner
      if (cleanInput.contains("hello") || cleanInput.contains("hi")) {
        reply = "Hello. Let us commence the speaking test. I will be evaluating your grammar, vocabulary coherence, and natural flow. For our first topic, let us discuss your occupation. What do you do for a living?";
      } else if (cleanInput.contains("hobby") || cleanInput.contains("sports") || cleanInput.contains("leisure")) {
        reply = "Indeed. Engaging in recreational activities is highly beneficial. To secure a higher band score, try using advanced idioms. Could you articulate the benefits of your hobbies using terms like 'stress-reliever' or 'intellectually stimulating'?";
      } else {
        reply = "Understood. That is a logical perspective. However, you might want to expand your response with cohesive devices such as 'Furthermore' or 'Consequently' to achieve a higher score. Shall we attempt another speaking prompt?";
      }
    }

    return {
      'corrected': corrected,
      'explanation': explanation,
      'reply': reply,
    };
  }
}
