import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AiService _aiService = AiService();
  
  String _mode = 'google';
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _ollamaUrlController = TextEditingController();
  final TextEditingController _ollamaModelController = TextEditingController();

  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _ollamaUrlController.dispose();
    _ollamaModelController.dispose();
    super.dispose();
  }

  // Load saved config into controllers
  Future<void> _loadConfig() async {
    final config = await _aiService.getConfig();
    setState(() {
      _mode = config['mode'] ?? 'google';
      _apiKeyController.text = config['apiKey'] ?? '';
      _ollamaUrlController.text = config['ollamaUrl'] ?? AiService.defaultOllamaUrl;
      _ollamaModelController.text = config['ollamaModel'] ?? AiService.defaultOllamaModel;
    });
  }

  // Save config
  Future<void> _saveConfig() async {
    await _aiService.saveConfig(
      mode: _mode,
      apiKey: _apiKeyController.text.trim(),
      ollamaUrl: _ollamaUrlController.text.trim(),
      ollamaModel: _ollamaModelController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('설정이 저장되었습니다.'),
            ],
          ),
          backgroundColor: const Color(0xFF2CB67D), // Emerald accent
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching Home Screen
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0B26),
                  Color(0xFF07070F),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom Navigation Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'AI 모델 설정',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.06), height: 1),
                
                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '연동 방식 선택',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Mode Selector Tab Buttons
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _mode = 'google'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: _mode == 'google'
                                        ? const Color(0xFF7F5AF0).withOpacity(0.12)
                                        : Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _mode == 'google'
                                          ? const Color(0xFF7F5AF0)
                                          : Colors.white.withOpacity(0.08),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_queue_rounded,
                                        color: _mode == 'google' ? const Color(0xFF7F5AF0) : Colors.white60,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Google AI API',
                                        style: TextStyle(
                                          color: _mode == 'google' ? Colors.white : Colors.white60,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _mode = 'ollama'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: _mode == 'ollama'
                                        ? const Color(0xFF7F5AF0).withOpacity(0.12)
                                        : Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _mode == 'ollama'
                                          ? const Color(0xFF7F5AF0)
                                          : Colors.white.withOpacity(0.08),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.computer_rounded,
                                        color: _mode == 'ollama' ? const Color(0xFF7F5AF0) : Colors.white60,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '로컬 Ollama',
                                        style: TextStyle(
                                          color: _mode == 'ollama' ? Colors.white : Colors.white60,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Form Section 1: Google AI
                        if (_mode == 'google') ...[
                          const Text(
                            'Google Generative AI Key',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: TextField(
                              controller: _apiKeyController,
                              obscureText: _isObscure,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'AI Studio API Key를 입력하세요',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white30,
                                  ),
                                  onPressed: () => setState(() => _isObscure = !_isObscure),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Help alert container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: const Color(0xFF7F5AF0).withOpacity(0.8), size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '무료 API 키 발급 방법',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Google AI Studio에서 무료로 개인 API 키를 발급받아 입력하시면 즉시 고성능 Gemma 4 모델 및 Gemini 모델 서비스를 무제한으로 사용하실 수 있습니다.',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Form Section 2: Ollama Local Connection
                          const Text(
                            'Ollama Endpoint URL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: TextField(
                              controller: _ollamaUrlController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'http://localhost:11434',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Gemma 4 로컬 모델명 (Model Name)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: TextField(
                              controller: _ollamaModelController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'gemma4:e2b',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.computer_rounded, color: const Color(0xFF7F5AF0).withOpacity(0.8), size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '로컬 실행 요건',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'PC/Mac 기기에 Ollama 서비스가 설치되어 있어야 하며, 터미널에서 아래의 모델 풀링 명령어를 통해 로컬에 모델 가중치를 다운로드하셔야 동작합니다.\n- 예: ollama pull gemma4:e2b',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Default Fallback Guide
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF15BB5).withOpacity(0.12),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Color(0xFFF15BB5), size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'API 키 또는 로컬 모델이 없더라도, 즉시 테스팅 및 데모 시연이 가능하도록 고감도의 인공지능 모크 시뮬레이션 엔진이 내장되어 있습니다. 자유롭게 일기를 써보세요!',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Save Button
                        GestureDetector(
                          onTap: _saveConfig,
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7F5AF0),
                                  Color(0xFF9D4EDD),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7F5AF0).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '설정 저장 및 적용하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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
}
