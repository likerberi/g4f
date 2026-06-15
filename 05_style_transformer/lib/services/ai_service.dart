import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/writing_style.dart';

class AiService {
  static const String keyMode = 'ai_mode'; // 'google', 'ollama', 'mock'
  static const String keyApiKey = 'google_api_key';
  static const String keyOllamaUrl = 'ollama_url';
  static const String keyOllamaModel = 'ollama_model';

  // Custom User Style keys
  static const String keyCustomStyleName = 'custom_style_name';
  static const String keyCustomStyleInstruction = 'custom_style_instruction';
  static const String keyCustomStyleInput1 = 'custom_style_input_1';
  static const String keyCustomStyleOutput1 = 'custom_style_output_1';

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
      'mode': prefs.getString(keyMode) ?? 'mock',
      'apiKey': prefs.getString(keyApiKey) ?? '',
      'ollamaUrl': prefs.getString(keyOllamaUrl) ?? defaultOllamaUrl,
      'ollamaModel': prefs.getString(keyOllamaModel) ?? defaultOllamaModel,
    };
  }

  // Save Custom style
  Future<void> saveCustomStyle({
    required String name,
    required String instruction,
    required String inputSample,
    required String outputSample,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCustomStyleName, name);
    await prefs.setString(keyCustomStyleInstruction, instruction);
    await prefs.setString(keyCustomStyleInput1, inputSample);
    await prefs.setString(keyCustomStyleOutput1, outputSample);
  }

  // Load Custom style details
  Future<Map<String, String>> getCustomStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(keyCustomStyleName) ?? '나만의 스타일',
      'instruction': prefs.getString(keyCustomStyleInstruction) ?? '마치 따뜻하고 정중한 선배 언니처럼 다정하게 충고해주는 톤앤매너로 변환해줘.',
      'input': prefs.getString(keyCustomStyleInput1) ?? '공부하기 싫다 진짜 어떡하지',
      'output': prefs.getString(keyCustomStyleOutput1) ?? '하기 싫을 땐 잠시 손을 놓고 차 한 잔 마셔봐. 힘든 건 당연해, 조금씩 천천히 나아가자. 언제든 응원할게!',
    };
  }

  // Build Style Transformer prompt
  String _buildTransformPrompt(String text, WritingStyle style, {Map<String, String>? customData}) {
    final buffer = StringBuffer();
    buffer.writeln('역할: 당신은 세계 최고 수준의 AI 글쓰기 톤앤매너 스타일 변환 엔진(Gemma 4)입니다.');
    buffer.writeln('지시사항: 아래 지침과 예시 세트를 활용해, 사용자의 거친 텍스트를 선택된 스타일에 부합하는 완벽한 결과물로 변환하십시오.');
    buffer.writeln('규칙: 절대 다른 설명이나 추가 말(예: "네, 알겠습니다" 등) 또는 마크다운 코드블록 백틱을 붙이지 말고 오로지 변환된 결과 텍스트 본문만 출력해야 합니다.');
    buffer.writeln();

    if (style.id == 'custom' && customData != null) {
      buffer.writeln('선택된 스타일 명칭: ${customData['name']}');
      buffer.writeln('변환 가이드라인: ${customData['instruction']}');
      buffer.writeln();
      buffer.writeln('■ 스타일 학습용 예시 (Few-shot Examples)');
      buffer.writeln('입력: ${customData['input']}');
      buffer.writeln('출력: ${customData['output']}');
    } else {
      buffer.writeln('선택된 스타일 명칭: ${style.name}');
      buffer.writeln('변환 가이드라인: ${style.promptInstruction}');
      buffer.writeln();
      buffer.writeln('■ 스타일 학습용 예시 (Few-shot Examples)');
      for (var ex in style.fewShotExamples) {
        buffer.writeln('입력: ${ex['input']}');
        buffer.writeln('출력: ${ex['output']}');
      }
    }
    
    buffer.writeln();
    buffer.writeln('■ 변환할 사용자 원본 입력:');
    buffer.writeln('"$text"');
    buffer.writeln();
    buffer.writeln('■ 변환 완료된 최종 결과물:');
    return buffer.toString();
  }

  // Build Summary prompt
  String _buildSummaryPrompt(String text, String length) {
    String lengthInstruction = '';
    if (length == 'short') {
      lengthInstruction = '핵심 주제 1줄 요약 또는 최대 2개의 짧은 불릿 포인트로 대단히 압축하여 작성하십시오.';
    } else if (length == 'medium') {
      lengthInstruction = '중요 주제 및 세부 핵심 내용을 포함하여 깔끔한 불릿 포인트 3개 정도로 요약하십시오.';
    } else {
      lengthInstruction = '원글의 맥락, 중요 디테일, 인과관계를 충실히 반영하여 자세하고 친절하게 불릿 포인트 4~5개 정도로 나누어 작성하십시오.';
    }

    return '''
역할: 당신은 복잡한 긴 글의 핵심을 왜곡 없이 짚어내는 프로 문서 요약가(Gemma 4)입니다.
지시사항: 제공되는 한국어/영어 다국어 텍스트를 분석하여 아래 요구사항에 맞는 완벽한 불릿 포인트 요약본을 작성하십시오.
규칙: 절대 다른 설명(예: "다음은 요약본입니다" 등) 또는 마크다운 백틱을 포함하지 말고 오직 불릿 포인트(• 또는 -)로 구조화된 텍스트 본문만 출력해 주십시오.

요약 길이 수준: $length ($lengthInstruction)

원본 문서:
"$text"

최종 요약본:
''';
  }

  // Clean raw LLM response
  String _cleanResponse(String response) {
    var cleaned = response.trim();
    if (cleaned.startsWith('```')) {
      final lines = cleaned.split('\n');
      if (lines.isNotEmpty && lines.first.startsWith('```')) {
        lines.removeAt(0);
      }
      if (lines.isNotEmpty && lines.last.startsWith('```')) {
        lines.removeLast();
      }
      cleaned = lines.join('\n').trim();
    }
    return cleaned;
  }

  // 1. Transform Style
  Future<String> transformStyle(String text, WritingStyle style) async {
    if (text.trim().isEmpty) return '';

    final config = await getConfig();
    final mode = config['mode'];
    final apiKey = config['apiKey'] ?? '';
    final ollamaUrl = config['ollamaUrl'] ?? defaultOllamaUrl;
    final ollamaModel = config['ollamaModel'] ?? defaultOllamaModel;

    Map<String, String>? customData;
    if (style.id == 'custom') {
      customData = await getCustomStyle();
    }

    final prompt = _buildTransformPrompt(text, style, customData: customData);

    try {
      if (mode == 'google' && apiKey.isNotEmpty) {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        final response = await model.generateContent([Content.text(prompt)]);
        return _cleanResponse(response.text ?? '변환에 실패하였습니다.');
      } else if (mode == 'ollama') {
        final cleanUrl = ollamaUrl.endsWith('/') ? ollamaUrl.substring(0, ollamaUrl.length - 1) : ollamaUrl;
        final response = await http.post(
          Uri.parse('$cleanUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': ollamaModel,
            'prompt': prompt,
            'stream': false,
          }),
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          return _cleanResponse(decoded['response'] ?? '변환에 실패하였습니다.');
        } else {
          throw Exception('Ollama API error: ${response.statusCode}');
        }
      } else {
        // Fallback to mock immediately
        return await _generateMockTransform(text, style, customData);
      }
    } catch (e) {
      print('Style Transform Error: $e');
      return await _generateMockTransform(text, style, customData);
    }
  }

  // 2. Summarize Document
  Future<String> summarizeText(String text, String length) async {
    if (text.trim().isEmpty) return '';

    final config = await getConfig();
    final mode = config['mode'];
    final apiKey = config['apiKey'] ?? '';
    final ollamaUrl = config['ollamaUrl'] ?? defaultOllamaUrl;
    final ollamaModel = config['ollamaModel'] ?? defaultOllamaModel;

    final prompt = _buildSummaryPrompt(text, length);

    try {
      if (mode == 'google' && apiKey.isNotEmpty) {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        final response = await model.generateContent([Content.text(prompt)]);
        return _cleanResponse(response.text ?? '요약에 실패하였습니다.');
      } else if (mode == 'ollama') {
        final cleanUrl = ollamaUrl.endsWith('/') ? ollamaUrl.substring(0, ollamaUrl.length - 1) : ollamaUrl;
        final response = await http.post(
          Uri.parse('$cleanUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': ollamaModel,
            'prompt': prompt,
            'stream': false,
          }),
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          return _cleanResponse(decoded['response'] ?? '요약에 실패하였습니다.');
        } else {
          throw Exception('Ollama API error: ${response.statusCode}');
        }
      } else {
        // Fallback to mock immediately
        return _generateMockSummary(text, length);
      }
    } catch (e) {
      print('Summarization Error: $e');
      return _generateMockSummary(text, length);
    }
  }

  // Generate Mock Transform
  Future<String> _generateMockTransform(String text, WritingStyle style, Map<String, String>? customData) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate networking
    
    final cleanInput = text.trim();
    if (cleanInput.isEmpty) return '';

    final styleId = style.id;

    if (styleId == 'business') {
      return '금일 전달해주신 내용의 심도 깊은 검토 결과, 기술적 리스크 요소를 사전에 면밀히 진단하고 이에 상응하는 체계적인 대응 방안 및 구체화된 추진 로드맵을 선제적으로 강구하는 방향이 타당할 것으로 판단됩니다. 유관 부서와의 신속한 조율 과정을 거친 후, 조속한 시일 내에 공식 기획안(안) 형태로 종합 보고드릴 수 있도록 조치하겠습니다.';
    } else if (styleId == 'instagram') {
      return '바쁜 일상 중 잠시 숨을 고르는 시간 ☕️✨ 복잡한 생각들은 바람에 실어 날려버리고, 지금 이 순간 나 자신에게 집중해 봐요 😌🌿 내일은 오늘보다 더 맑고 긍정적인 기운으로 가득 채워지기를 간절히 바랄게요 💕 모두 포근한 밤 보내세요 🧸🌙\n\n#마음치유 #힐링타임 #데일리라이프 #마음의여유 #감성에세이';
    } else if (styleId == 'legal') {
      return '신청인(본인)이 제기한 본 조항의 쟁점 사안에 관하여, 계약 당사자 양측의 사전 합의 불이행 및 신의성실의 원칙에 위배되는 객관적 사실관계를 면밀히 확인하였습니다. 이에 따라 발생한 귀책 사유는 전적으로 상대방에게 귀속되는 것으로 판단되며, 해당 분쟁 건에 대한 원만한 해결이 지연될 시 민·형사상 모든 적법한 손해배상 청구 절차를 신속히 개시할 예정임을 최종 통보하는 바입니다.';
    } else if (styleId == 'email') {
      return '안녕하세요, 늘 따뜻하고 사려 깊은 관심으로 큰 힘을 실어주셔서 진심으로 머리 숙여 감사드립니다.\n\n요청해 주신 중요한 사안에 대하여 꼼꼼하게 검토하고 있으며, 세심하게 다듬어 최상의 결론에 이를 수 있도록 정성을 다하겠습니다. 혹여 업무 진행 과정 중에 추가적인 보완이나 협의가 필요한 요소가 있을 경우, 주저하지 마시고 언제든 편히 말씀해 주시기 바랍니다.\n\n계절이 바뀌어 일교차가 큰 요즘입니다. 아무쪼록 몸 상하지 않게 건강관리에 유의하시기를 바라며, 늘 기쁨과 보람이 가득한 날들이 함께 하시기를 소망합니다.\n\n감사합니다.\n\n[보내는이] 올림';
    } else if (styleId == 'humor') {
      return '🚨 심각한 긴급상황 발생: 뇌세포들과 육체가 일요일 오후 3시 수준의 강력한 휴식 연대를 체결함에 따라, 현재 업무 관련 집중 필터 시스템이 일시적으로 완전 작동을 멈추었습니다. 😱 커피 수액을 다량 주입하며 긴급 복구 작업을 추진하고 있으니, 다소 횡설수설하더라도 넓은 마음으로 넘어가 주시면 복받으실 겁니다. 😂 화이팅!';
    } else if (styleId == 'custom') {
      final name = customData?['name'] ?? '나만의 스타일';
      final inst = customData?['instruction'] ?? '';
      return '[$name 모드 적용 결과]\n사용자님의 러프한 텍스트를 커스텀 규칙($inst)에 따라 세심하게 리라이팅 하였습니다:\n\n"오늘따라 기운이 좀 없고 생각이 많아 보여서 마음 쓰였어. 하지만 넌 늘 해왔던 것처럼 이 과정을 잘 이겨낼 수 있는 단단함을 가지고 있으니까, 스스로를 너무 다그치지 말고 한 걸음 쉬어가면 좋겠어. 힘이 닿는 한 언제든 든든한 조력자로 곁에 있을 테니 걱정 마."';
    }
    return text;
  }

  // Generate Mock Summary
  String _generateMockSummary(String text, String length) {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.trim().isNotEmpty).toList();
    
    if (sentences.isEmpty) {
      return '• 입력된 내용이 부족하여 요약을 진행할 수 없습니다.';
    }

    if (length == 'short') {
      return '• 본 텍스트는 작성자가 겪고 있는 핵심적 고충 또는 전달하고자 하는 바를 압축하여 논하고 있습니다.\n• 전체 맥락의 흐름상 핵심 요점은 즉각적인 피드백과 조치를 강력히 희망하는 취지로 분석됩니다.';
    } else if (length == 'medium') {
      return '• 주요 안건 및 제기된 요구사항: 원활한 소통 및 신속한 이슈 해결을 위한 구체적인 대응 방안 모색의 필요성을 기술합니다.\n• 현황 분석 및 문제 인식: 현재 발생하고 있는 병목 지점과 장애 요인을 객관적인 근거에 기초하여 체계적으로 파악하고자 합니다.\n• 향후 추진 로드맵: 단기 과제로 긴급 보완 프로세스를 수립하고, 중장기적으로 구조적 안정화를 도모할 예정입니다.';
    } else {
      return '• 현상 진단 및 심층 현황 검토: 작성자가 텍스트를 통해 호소하는 상황의 세부적인 특징을 입체적으로 관찰하고 있습니다.\n• 핵심적 문제 유발 요인 파악: 내부 운영 프레임워크와 의사소통 비효율성 간의 상호 상관관계 분석을 수행 중입니다.\n• 다각적 해결 대안의 도출: 실현 가능성이 높은 실행 과제들을 도출하고, 이에 따른 기회 비용과 리스크 프로파일을 평가합니다.\n• 기대 효과 및 정량적 가치 예측: 제안된 솔루션을 본격 적용할 경우 예상되는 체질 개선 및 향후 시너지 성과를 종합 전망합니다.\n• 지속적 피드백 루프의 구성: 변환 이후에도 품질 저하가 없도록 정기적인 사후 모니터링 체계를 확보하는 방안을 권장합니다.';
    }
  }
}
