import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AiService _aiService = AiService();
  
  String _mode = 'mock'; // 'mock', 'google', 'ollama'
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _ollamaUrlController = TextEditingController();
  final TextEditingController _ollamaModelController = TextEditingController();

  bool _isObscure = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _aiService.getConfig();
    setState(() {
      _mode = config['mode'] ?? 'mock';
      _apiKeyController.text = config['apiKey'] ?? '';
      _ollamaUrlController.text = config['ollamaUrl'] ?? AiService.defaultOllamaUrl;
      _ollamaModelController.text = config['ollamaModel'] ?? AiService.defaultOllamaModel;
    });
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    await _aiService.saveConfig(
      mode: _mode,
      apiKey: _apiKeyController.text.trim(),
      ollamaUrl: _ollamaUrlController.text.trim(),
      ollamaModel: _ollamaModelController.text.trim(),
    );
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '설정이 저장되었습니다!',
            style: GoogleFonts.notoSansKr(color: Colors.white),
          ),
          backgroundColor: Colors.teal.shade700,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _ollamaUrlController.dispose();
    _ollamaModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI 서비스 연결 설정',
          style: GoogleFonts.notoSansKr(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9F43).withOpacity(0.1),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              children: [
                // Mode Select Header
                Text(
                  '플래너 연동 모드',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Mock Mode Button
                _buildModeTile(
                  'mock',
                  '오프라인 스마트 모드 (추천)',
                  '인공지능 기반의 지리적 TSP 알고리즘이 100대 명소를 정교하게 분석하여 즉시 일정을 짜줍니다. API 키 설정 없이 100% 무결성으로 즉각 실행됩니다.',
                  Icons.offline_bolt,
                ),
                const SizedBox(height: 12),

                // Google Gemini Mode Button
                _buildModeTile(
                  'google',
                  'Google Gemini API',
                  'Google AI Studio에서 제공하는 gemini-1.5-flash 모델을 사용하여 자유롭고 풍부한 텍스트로 맞춤 계획을 짜줍니다. API Key 필요.',
                  Icons.auto_awesome,
                ),
                const SizedBox(height: 12),

                // Ollama Mode Button
                _buildModeTile(
                  'ollama',
                  'Ollama Local LLM',
                  '로컬 PC에서 실행 중인 Ollama 서버(gemma4:e2b 등)를 연동하여 인터넷 연결 없이 온디바이스 인공지능 플랜을 세웁니다.',
                  Icons.computer,
                ),

                const SizedBox(height: 28),

                // Mode-dependent Input forms
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _mode == 'google'
                      ? _buildGoogleSettings()
                      : _mode == 'ollama'
                          ? _buildOllamaSettings()
                          : const SizedBox.shrink(),
                ),

                const SizedBox(height: 40),

                // Save button
                GestureDetector(
                  onTap: _isSaving ? null : _saveConfig,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D9488),
                          Colors.teal.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              '설정 저장 및 뒤로가기',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTile(
    String modeType,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _mode == modeType;

    return GestureDetector(
      onTap: () {
        setState(() => _mode = modeType);
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2638) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF9F43).withOpacity(0.7)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9F43).withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF9F43) : Colors.white60,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.white38,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSettings() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Google AI Studio API Key 설정',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gemini 모델 호출을 위한 API Key를 입력하세요.',
            style: GoogleFonts.notoSansKr(fontSize: 11, color: Colors.white38),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            obscureText: _isObscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              hintText: 'AI Studio API Key',
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.key, color: Colors.white54),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() => _isObscure = !_isObscure);
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF9F43)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOllamaSettings() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ollama 로컬 서버 설정',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ollama URL',
            style: GoogleFonts.notoSansKr(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ollamaUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              hintText: 'http://localhost:11434',
              hintStyle: const TextStyle(color: Colors.white30),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF9F43)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '모델명',
            style: GoogleFonts.notoSansKr(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ollamaModelController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              hintText: 'gemma4:e2b',
              hintStyle: const TextStyle(color: Colors.white30),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF9F43)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
