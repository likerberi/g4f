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

  // Load config into controllers
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
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                '설정이 저장되었습니다.',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
              ),
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
          // Deep cosmic gradient
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
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.06),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'AI 설정 및 연동',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Mode Selection Header
                        Text(
                          'AI 연동 모드 선택',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A1B2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Segmented buttons
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _mode = 'google'),
                                child: _buildModeCard(
                                  title: 'Google AI Studio',
                                  subtitle: 'Gemini-1.5-Flash (추천)',
                                  icon: Icons.cloud_queue_rounded,
                                  isActive: _mode == 'google',
                                  activeColor: const Color(0xFF7F5AF0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _mode = 'ollama'),
                                child: _buildModeCard(
                                  title: 'Local Ollama',
                                  subtitle: 'gemma4:e2b (온디바이스)',
                                  icon: Icons.lan_rounded,
                                  isActive: _mode == 'ollama',
                                  activeColor: const Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Render config fields based on selection
                        if (_mode == 'google') ...[
                          _buildFieldHeader('Google Gemini API Key'),
                          const SizedBox(height: 8),
                          _buildGlassTextField(
                            controller: _apiKeyController,
                            hintText: 'AI Studio API 키 입력',
                            obscureText: _isObscure,
                            prefixIcon: Icons.vpn_key_outlined,
                            suffix: IconButton(
                              icon: Icon(
                                _isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: const Color(0xFF94A1B2),
                              ),
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7F5AF0).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF7F5AF0).withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Color(0xFF94A1B2), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Google AI Studio API Key가 등록되지 않았거나 네트워크 연결이 유실되었을 경우, 똑똑하게 동작하는 오프라인 캘린더 추출 로컬 시뮬레이션(Mock Engine)이 즉각 작동합니다.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: const Color(0xFF94A1B2),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          _buildFieldHeader('Ollama Server URL'),
                          const SizedBox(height: 8),
                          _buildGlassTextField(
                            controller: _ollamaUrlController,
                            hintText: 'http://localhost:11434',
                            prefixIcon: Icons.link_rounded,
                          ),
                          const SizedBox(height: 24),
                          _buildFieldHeader('Ollama Model Name'),
                          const SizedBox(height: 8),
                          _buildGlassTextField(
                            controller: _ollamaModelController,
                            hintText: 'gemma4:e2b',
                            prefixIcon: Icons.model_training_rounded,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF00E5FF).withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Color(0xFF94A1B2), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '로컬에 Ollama가 설치되어 있고 Gemma 4 모델이 기동 중이어야 정상 연동됩니다. (예: terminal에서 "ollama run gemma4:e2b" 명령어 실행)',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: const Color(0xFF94A1B2),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 48),

                        // Action button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: _mode == 'google'
                                  ? [const Color(0xFF7F5AF0), const Color(0xFFA78BFA)]
                                  : [const Color(0xFF00E5FF), const Color(0xFF00B4D8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_mode == 'google' ? const Color(0xFF7F5AF0) : const Color(0xFF00E5FF)).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _saveConfig,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              '설정 저장하기',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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

  Widget _buildFieldHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF94A1B2),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.8) : Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : const Color(0xFF94A1B2),
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: const Color(0xFF94A1B2),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(color: const Color(0xFF727F90), fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A1B2), size: 20),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
