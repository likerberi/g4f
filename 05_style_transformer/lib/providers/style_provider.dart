import 'package:flutter/material.dart';
import '../models/writing_style.dart';
import '../services/ai_service.dart';

class StyleProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  String _inputText = '';
  WritingStyle _selectedStyle = defaultStyles.first;
  String _outputText = '';
  bool _isTransforming = false;

  double _summaryLengthValue = 1.0; // 0.0: short, 1.0: medium, 2.0: detailed
  String _summarizedText = '';
  bool _isSummarizing = false;

  // Custom Style State
  String _customStyleName = '나만의 스타일';
  String _customStyleInstruction = '친근한 사투리를 섞어 조언해 주는 사려 깊은 대화체';
  String _customStyleInput = '공부하기 싫다 진짜 어떡하지';
  String _customStyleOutput = '아이고~ 공부가 와이래 손에 안 잡히노! 억지로 잡고 있어봤자 머리만 지끈하지. 바람 쐬고 온나. 괘안타!';

  // Getters
  String get inputText => _inputText;
  WritingStyle get selectedStyle => _selectedStyle;
  String get outputText => _outputText;
  bool get isTransforming => _isTransforming;

  double get summaryLengthValue => _summaryLengthValue;
  String get summarizedText => _summarizedText;
  bool get isSummarizing => _isSummarizing;

  String get customStyleName => _customStyleName;
  String get customStyleInstruction => _customStyleInstruction;
  String get customStyleInput => _customStyleInput;
  String get customStyleOutput => _customStyleOutput;

  // Convert summary slider value to string key
  String get summaryLengthKey {
    if (_summaryLengthValue < 0.5) return 'short';
    if (_summaryLengthValue < 1.5) return 'medium';
    return 'detailed';
  }

  String get summaryLengthLabel {
    if (_summaryLengthValue < 0.5) return '짧게 (한 줄 요약)';
    if (_summaryLengthValue < 1.5) return '보통 (핵심 3단 요약)';
    return '자세히 (상세 맥락 포함 요약)';
  }

  StyleProvider() {
    _loadCustomStyleData();
  }

  // Load Custom Style Info
  Future<void> _loadCustomStyleData() async {
    final customData = await _aiService.getCustomStyle();
    _customStyleName = customData['name'] ?? '나만의 스타일';
    _customStyleInstruction = customData['instruction'] ?? '친근한 사투리를 섞어 조언해 주는 사려 깊은 대화체';
    _customStyleInput = customData['input'] ?? '공부하기 싫다 진짜 어떡하지';
    _customStyleOutput = customData['output'] ?? '아이고~ 공부가 와이래 손에 안 잡히노! 억지로 잡고 있어봤자 머리만 지끈하지. 바람 쐬고 온나. 괘안타!';
    notifyListeners();
  }

  // Set Input Text
  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  // Select Writing Style
  void selectStyle(WritingStyle style) {
    _selectedStyle = style;
    notifyListeners();
  }

  // Select Custom Style specifically
  void selectCustomStyle() {
    // Create a dynamic WritingStyle instance for custom
    final customStyle = WritingStyle(
      id: 'custom',
      name: _customStyleName,
      description: '내가 커스터마이징한 전용 AI 필체',
      icon: Icons.edit_note_rounded,
      promptInstruction: _customStyleInstruction,
      fewShotExamples: [
        {'input': _customStyleInput, 'output': _customStyleOutput}
      ],
    );
    _selectedStyle = customStyle;
    notifyListeners();
  }

  // Set Summary Length Value
  void setSummaryLength(double value) {
    _summaryLengthValue = value;
    notifyListeners();
  }

  // Save Custom Style Config
  Future<void> saveCustomStyle({
    required String name,
    required String instruction,
    required String input,
    required String output,
  }) async {
    _customStyleName = name;
    _customStyleInstruction = instruction;
    _customStyleInput = input;
    _customStyleOutput = output;
    
    await _aiService.saveCustomStyle(
      name: name,
      instruction: instruction,
      inputSample: input,
      outputSample: output,
    );

    // If currently selected style is custom, update it
    if (_selectedStyle.id == 'custom') {
      selectCustomStyle();
    } else {
      notifyListeners();
    }
  }

  // Transform Writing Style
  Future<void> transformText() async {
    if (_inputText.trim().isEmpty) return;

    _isTransforming = true;
    _outputText = '';
    notifyListeners();

    try {
      _outputText = await _aiService.transformStyle(_inputText, _selectedStyle);
    } catch (e) {
      _outputText = '스타일 변환에 실패했습니다. 오류: $e';
    } finally {
      _isTransforming = false;
      notifyListeners();
    }
  }

  // Summarize Writing Text
  Future<void> summarizeInput() async {
    // Summarizes the INPUT text or OUTPUT text depending on choice. We will summarize the output text if present, otherwise input.
    final targetText = _outputText.isNotEmpty ? _outputText : _inputText;
    if (targetText.trim().isEmpty) return;

    _isSummarizing = true;
    _summarizedText = '';
    notifyListeners();

    try {
      _summarizedText = await _aiService.summarizeText(targetText, summaryLengthKey);
    } catch (e) {
      _summarizedText = '요약 생성에 실패했습니다. 오류: $e';
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  // Clear All
  void clearAll() {
    _inputText = '';
    _outputText = '';
    _summarizedText = '';
    notifyListeners();
  }
}
