import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/writing_style.dart';
import '../providers/style_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Open Custom Style editor dialog
  void _showCustomStyleEditor(BuildContext context, StyleProvider provider) {
    final nameController = TextEditingController(text: provider.customStyleName);
    final instructionController = TextEditingController(text: provider.customStyleInstruction);
    final inputController = TextEditingController(text: provider.customStyleInput);
    final outputController = TextEditingController(text: provider.customStyleOutput);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161623),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: Color(0xFF7F5AF0)),
            const SizedBox(width: 10),
            Text(
              '나만의 스타일 편집',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('스타일 이름', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildDialogField(nameController, '예: 사투리 할배체, 고전 판타지풍 등'),
                
                const SizedBox(height: 16),
                const Text('AI 스타일 지시사항 (Instruction)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildDialogField(instructionController, '예: 푸근한 사투리를 섞어 조언하듯이...', maxLines: 2),
                
                const SizedBox(height: 16),
                const Text('학습용 원본 입력 예시 (Few-shot Input)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildDialogField(inputController, '예: 너무 졸려 죽겠네'),
                
                const SizedBox(height: 16),
                const Text('학습용 변환 결과 예시 (Few-shot Output)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildDialogField(outputController, '예: 우리 강아지 많이 졸리구먼, 얼릉 발 닦고 자거라!', maxLines: 2),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Color(0xFF94A1B2))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty || instructionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('스타일 이름과 지시사항은 필수 항목입니다.'),
                    backgroundColor: const Color(0xFFFF4E50),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
                return;
              }
              provider.saveCustomStyle(
                name: nameController.text.trim(),
                instruction: instructionController.text.trim(),
                input: inputController.text.trim(),
                output: outputController.text.trim(),
              );
              Navigator.pop(ctx);
              
              // Trigger custom style selection
              provider.selectCustomStyle();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${nameController.text}" 스타일이 저장 및 적용되었습니다.'),
                  backgroundColor: const Color(0xFF2CB67D),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F5AF0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('저장 및 적용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  // Helper to copy text to clipboard
  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy_all_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('$label 복사되었습니다.'),
          ],
        ),
        backgroundColor: const Color(0xFF2CB67D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Helper to share text (mock)
  void _shareText(String text) {
    if (text.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('외부로 공유하기 창이 열렸습니다:\n"${text.substring(0, text.length > 30 ? 30 : text.length)}..."')),
          ],
        ),
        backgroundColor: const Color(0xFF7F5AF0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StyleProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (Deep cosmic navy-black)
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
                // Glassmorphic Custom Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7F5AF0), Color(0xFFF15BB5)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GemmaStyle',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const Text(
                                'AI 톤앤매너 텍스트 마스터',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.06), height: 1),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Raw Input Section
                        const Text(
                          '날 것의 생각 / rough 메모 입력',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161623),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _inputController,
                                maxLines: 4,
                                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                                decoration: const InputDecoration(
                                  hintText: '오늘 일정 끝! 너무 귀찮아서 보고서 미루고 싶은데 어쩌지... 내일 아침까지 내야 되는데 큰일났다.',
                                  hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                onChanged: (text) => provider.setInputText(text),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_inputController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                                      onPressed: () {
                                        _inputController.clear();
                                        provider.clearAll();
                                      },
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.paste_rounded, color: Color(0xFF7F5AF0), size: 20),
                                    onPressed: () async {
                                      final data = await Clipboard.getData('text/plain');
                                      if (data?.text != null) {
                                        setState(() {
                                          _inputController.text = data!.text!;
                                          provider.setInputText(data.text!);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Writing Style Selector Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '전환할 AI 필체 톤앤매너 선택',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            if (provider.selectedStyle.id == 'custom')
                              GestureDetector(
                                onTap: () => _showCustomStyleEditor(context, provider),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit_rounded, color: Color(0xFFF15BB5), size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      '커스텀 편집',
                                      style: TextStyle(color: Color(0xFFF15BB5), fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Horizontal chips list
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: defaultStyles.length + 1,
                            itemBuilder: (context, index) {
                              final bool isLast = index == defaultStyles.length;
                              final WritingStyle style;
                              final bool isSelected;
                              final String iconText;

                              if (isLast) {
                                style = WritingStyle(
                                  id: 'custom',
                                  name: provider.customStyleName,
                                  description: '사용자가 직접 조립하는 커스텀 few-shot 필체',
                                  icon: Icons.edit_note_rounded,
                                  promptInstruction: provider.customStyleInstruction,
                                  fewShotExamples: const [],
                                );
                                isSelected = provider.selectedStyle.id == 'custom';
                                iconText = '✏️';
                              } else {
                                style = defaultStyles[index];
                                isSelected = provider.selectedStyle.id == style.id;
                                if (style.id == 'business') {
                                  iconText = '💼';
                                } else if (style.id == 'instagram') {
                                  iconText = '📸';
                                } else if (style.id == 'legal') {
                                  iconText = '⚖️';
                                } else if (style.id == 'email') {
                                  iconText = '✉️';
                                } else {
                                  iconText = '💡';
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: InkWell(
                                  onTap: () {
                                    if (isLast) {
                                      provider.selectCustomStyle();
                                    } else {
                                      provider.selectStyle(style);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 130,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFF7F5AF0).withOpacity(0.12)
                                          : const Color(0xFF161623),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFF7F5AF0) 
                                            : Colors.white.withOpacity(0.06),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(iconText, style: const TextStyle(fontSize: 18)),
                                            Icon(
                                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                              color: isSelected ? const Color(0xFF7F5AF0) : Colors.white24,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          style.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.white70,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Selected style description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            provider.selectedStyle.id == 'custom' 
                                ? '🔧 가이드라인: ${provider.customStyleInstruction}'
                                : 'ℹ️ 필체 소개: ${provider.selectedStyle.description}',
                            style: const TextStyle(color: Color(0xFF94A1B2), fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Action Button (Transform)
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: provider.inputText.trim().isEmpty
                                  ? [Colors.grey.shade800, Colors.grey.shade900]
                                  : [const Color(0xFF7F5AF0), const Color(0xFFF15BB5)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: provider.inputText.trim().isEmpty ? [] : [
                              BoxShadow(
                                color: const Color(0xFF7F5AF0).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: provider.inputText.trim().isEmpty ? null : () => provider.transformText(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            ),
                            child: provider.isTransforming
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.spellcheck_rounded, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        '"${provider.selectedStyle.name}" 스타일로 대변환',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Transformed Output Section
                        if (provider.isTransforming || provider.outputText.isNotEmpty) ...[
                          const Text(
                            '✨ 변환 결과 (Transformed Text)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF161623),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFF7F5AF0).withOpacity(0.15)),
                              ),
                              padding: const EdgeInsets.all(18),
                              child: provider.isTransforming
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24.0),
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(color: Color(0xFF7F5AF0)),
                                            SizedBox(height: 16),
                                            Text(
                                              'Gemma 4 스타일 필체 조립 중...',
                                              style: TextStyle(color: Colors.white54, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SelectableText(
                                          provider.outputText,
                                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Divider(color: Colors.white.withOpacity(0.05)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.copy_rounded, color: Color(0xFF2CB67D), size: 18),
                                              onPressed: () => _copyToClipboard(provider.outputText, '변환 텍스트가'),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.share_rounded, color: Color(0xFF7F5AF0), size: 18),
                                              onPressed: () => _shareText(provider.outputText),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Summarizer Section
                        if (provider.outputText.isNotEmpty || provider.inputText.isNotEmpty) ...[
                          const Text(
                            '📄 실시간 스마트 요약기 (Summarizer)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '변환된 결과글(또는 원본 글)을 원하는 길이의 핵심 불릿포인트 리스트로 정리합니다.',
                            style: TextStyle(color: Color(0xFF94A1B2), fontSize: 12),
                          ),
                          const SizedBox(height: 14),
                          
                          // Length selection slider
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161623),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.04)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('요약 디테일 레벨', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    Text(
                                      provider.summaryLengthLabel,
                                      style: const TextStyle(color: Color(0xFFF15BB5), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: provider.summaryLengthValue,
                                  min: 0.0,
                                  max: 2.0,
                                  divisions: 2,
                                  activeColor: const Color(0xFF7F5AF0),
                                  inactiveColor: Colors.white.withOpacity(0.08),
                                  onChanged: (val) => provider.setSummaryLength(val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Summarize button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: provider.isSummarizing ? null : () => provider.summarizeInput(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF7F5AF0), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: provider.isSummarizing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Color(0xFF7F5AF0), strokeWidth: 2),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.summarize_rounded, color: Color(0xFF7F5AF0), size: 18),
                                        SizedBox(width: 8),
                                        Text('불릿 포인트 핵심 요약 생성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                            ),
                          ),
                          
                          // Summarized Output
                          if (provider.isSummarizing || provider.summarizedText.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161623),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFF15BB5).withOpacity(0.15)),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: provider.isSummarizing
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(color: Color(0xFFF15BB5)),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            provider.summarizedText,
                                            style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.6),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.copy_rounded, color: Color(0xFF2CB67D), size: 18),
                                                onPressed: () => _copyToClipboard(provider.summarizedText, '요약문이'),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
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
