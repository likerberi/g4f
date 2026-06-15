import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../providers/style_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AiService _aiService = AiService();
  
  String _mode = 'mock';
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

  // Load saved config
  Future<void> _loadConfig() async {
    final config = await _aiService.getConfig();
    setState(() {
      _mode = config['mode'] ?? 'mock';
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
          backgroundColor: const Color(0xFF2CB67D), // Emerald
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  // Confirm Reset Custom Style
  void _confirmResetCustomStyle() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161623),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4E50)),
            SizedBox(width: 10),
            Text('커스텀 스타일 초기화', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          '저장된 "나만의 커스텀 스타일" 설정과 학습 예시 데이터를 초기 상태로 완전히 초기화하시겠습니까?',
          style: TextStyle(color: Color(0xFF94A1B2)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Color(0xFF94A1B2))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<StyleProvider>(context, listen: false);
              await provider.saveCustomStyle(
                name: '나만의 스타일',
                instruction: '친근한 사투리를 섞어 조언해 주는 사려 깊은 대화체',
                input: '공부하기 싫다 진짜 어떡하지',
                output: '아이고~ 공부가 와이래 손에 안 잡히노! 억지로 잡고 있어봤자 머리만 지끈하지. 바람 쐬고 온나. 괘안타!',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('커스텀 스타일이 기본값으로 초기화되었습니다.'),
                    backgroundColor: const Color(0xFFFF4E50),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4E50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('초기화 실행', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching app theme
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
                // Navigation Bar
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
                        
                        // Mode Selector Tab Buttons (Google, Ollama, Mock)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildTabButton('google', Icons.cloud_queue_rounded, 'Google AI'),
                                  const SizedBox(width: 4),
                                  _buildTabButton('ollama', Icons.computer_rounded, '로컬 Ollama'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildTabButton('mock', Icons.animation_rounded, '모의 변환 시뮬레이션'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Section: Google AI
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
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: TextField(
                              controller: _apiKeyController,
                              obscureText: _isObscure,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'AI Studio에서 발급받은 API Key 입력',
                                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () => setState(() => _isObscure = !_isObscure),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '💡 Gemini 1.5 Flash 모델을 활용해 실시간으로 한국어/영어 텍스트 스타일 변환과 지능형 불릿포인트 요약을 수행합니다.',
                            style: TextStyle(color: Color(0xFF72757A), fontSize: 13, height: 1.4),
                          ),
                        ],

                        // Form Section: Ollama Local
                        if (_mode == 'ollama') ...[
                          const Text(
                            'Ollama 서버 주소 (URL)',
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
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: TextField(
                              controller: _ollamaUrlController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '예: http://localhost:11434',
                                hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Ollama 텍스트 모델명 (Model)',
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
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: TextField(
                              controller: _ollamaModelController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '예: gemma4:e2b 또는 gemma2',
                                hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '💡 로컬 데스크톱의 Ollama 서버에 구동 중인 Gemma 4 등의 경량 LLM 모델을 활용해 오프라인 온디바이스 AI 환경을 구축합니다.',
                            style: TextStyle(color: Color(0xFF72757A), fontSize: 13, height: 1.4),
                          ),
                        ],

                        // Form Section: Mock Simulator
                        if (_mode == 'mock') ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161623),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF7F5AF0).withOpacity(0.15)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, color: Color(0xFF7F5AF0)),
                                    SizedBox(width: 8),
                                    Text(
                                      '오프라인 시뮬레이터 작동 중',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'API 키나 Ollama 서버가 연결되어 있지 않아도 5가지 이상의 고성능 AI 필체 전환 기능과 길이 조절 슬라이더에 따른 불릿포인트 요약 알고리즘을 완벽하게 체험해 볼 수 있는 모드입니다.',
                                  style: TextStyle(color: Color(0xFF94A1B2), fontSize: 13, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 48),
                        Divider(color: Colors.white.withOpacity(0.06)),
                        const SizedBox(height: 16),
                        
                        // Custom Style Management
                        const Text(
                          '커스텀 데이터 관리',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Reset Custom Style Button
                        GestureDetector(
                          onTap: _confirmResetCustomStyle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4E50).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFF4E50).withOpacity(0.2)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.refresh_rounded, color: Color(0xFFFF4E50)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '나만의 커스텀 스타일 초기화',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '커스텀 규칙 및 작성된 입출력 예시 데이터가 기본값으로 복구됩니다.',
                                        style: TextStyle(color: Color(0xFF94A1B2), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: Colors.white30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Save Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F5AF0), Color(0xFFF15BB5)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7F5AF0).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        '설정 저장 및 적용',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  // Tab Button Builder
  Widget _buildTabButton(String modeVal, IconData icon, String text) {
    final isSelected = _mode == modeVal;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = modeVal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7F5AF0).withOpacity(0.12) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF7F5AF0) : Colors.white.withOpacity(0.06),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF7F5AF0) : Colors.white38,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
