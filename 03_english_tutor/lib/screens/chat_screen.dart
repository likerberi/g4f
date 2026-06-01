import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/tutor_provider.dart';
import '../widgets/grammar_card.dart';
import '../widgets/voice_visualizer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _listeningTimer;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _listeningTimer?.cancel();
    super.dispose();
  }

  // Scroll to bottom of message list
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Handle text message submission
  void _handleSubmitted(String text, TutorProvider provider) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    provider.sendMessage(text);
    _scrollToBottom();
  }

  // Simulate Speak Microphone input
  void _handleMicPressed(TutorProvider provider) {
    provider.toggleListening();
    _scrollToBottom();

    if (provider.isListening) {
      // Mock vocal speaking input simulation after 3 seconds
      _listeningTimer = Timer(const Duration(milliseconds: 3500), () {
        if (provider.isListening) {
          provider.stopListening();
          
          // Let's suggest some typical Korean grammar mistakes randomly
          final listMistakes = [
            "I want to ordering coffee here",
            "She go to school by bus everyday",
            "I am agree with your opinion",
            "He don't like reading books",
            "I look forward to see you tomorrow",
            "I have a lot of homeworks to do",
          ];
          final selectedText = (listMistakes..shuffle()).first;
          
          provider.sendMessage(selectedText);
          _scrollToBottom();
        }
      });
    } else {
      _listeningTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TutorProvider>(context);
    final character = provider.activeCharacter;
    final messages = provider.messages;

    // Trigger auto-scroll when loading states or lists change
    if (provider.isLoading) {
      _scrollToBottom();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background space cosmic gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF07070F),
                  Color(0xFF0F0B26),
                  Color(0xFF07070F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 1. Premium Character Header
                _buildHeader(context, provider),

                // 2. Main Chat Messages List
                Expanded(
                  child: messages.isEmpty
                      ? _buildIntroductoryGreeting(provider)
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _buildMessageRow(message, provider);
                          },
                        ),
                ),

                // 3. Audio wave speaker visualizer
                VoiceVisualizer(
                  isActive: provider.isListening,
                  themeColor: character.themeColor,
                ),

                // 4. Thinking typing indicator
                if (provider.isLoading) _buildThinkingIndicator(character),

                // 5. Input Control Bar
                _buildInputBar(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header Bar with avatar details
  Widget _buildHeader(BuildContext context, TutorProvider provider) {
    final char = provider.activeCharacter;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              provider.stopListening();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.04),
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(width: 12),
          // Glowing Avatar Emoji
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: char.themeColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: char.themeColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(char.avatarEmoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          // Character names
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  char.name,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  char.role,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: char.themeColor,
                  ),
                ),
              ],
            ),
          ),
          // Clear history / Reset button
          IconButton(
            onPressed: () => _showResetConfirmDialog(context, provider),
            icon: const Icon(Icons.cleaning_services_rounded, color: Color(0xFFFF8E8E), size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFF8E8E).withOpacity(0.06),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  // Large introductory screen in case of empty state
  Widget _buildIntroductoryGreeting(TutorProvider provider) {
    final char = provider.activeCharacter;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                char.avatarEmoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                'Let\'s practice English!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '아래 텍스트 창에 영어로 입력하시거나 마이크를 클릭해 말씀해 보세요! 문법적 오류가 있으면 친절하게 정정해 드릴게요.',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF94A1B2),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row encapsulating bubble layout
  Widget _buildMessageRow(ChatMessage message, TutorProvider provider) {
    final char = provider.activeCharacter;
    final isUser = message.sender == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Avatar for AI
            Container(
              margin: const EdgeInsets.only(top: 4, right: 10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: char.themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: char.themeColor.withOpacity(0.2), width: 1),
              ),
              child: Text(char.avatarEmoji, style: const TextStyle(fontSize: 14)),
            ),
          ],
          
          // Bubbles
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Speech bubble Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? const Color(0xFF32324D).withOpacity(0.5) 
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isUser 
                          ? Colors.white.withOpacity(0.08) 
                          : char.themeColor.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          color: Colors.white,
                          height: 1.45,
                        ),
                      ),
                      
                      // Audio Speaker controls for Tutor responses
                      if (!isUser) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => provider.toggleTts(message),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                message.isPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                                size: 14,
                                color: message.isPlaying ? char.themeColor : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                message.isPlaying ? 'Speaking...' : 'Listen TTS',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: message.isPlaying ? char.themeColor : const Color(0xFF64748B),
                                ),
                              ),
                              if (message.isPlaying) ...[
                                const SizedBox(width: 6),
                                _buildSpeechPulse(char.themeColor),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Embedded Grammar card if mistakes were caught by Gemma
                if (!isUser && message.correction != null)
                  GrammarCard(
                    correction: message.correction!,
                    themeColor: char.themeColor,
                  ),
              ],
            ),
          ),
          
          if (isUser) const SizedBox(width: 40), // Spacing helper
          if (!isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  // Glowing miniature audio wave for TTS simulation
  Widget _buildSpeechPulse(Color color) {
    return Row(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 2,
          height: 8 + (index * 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // Thinking dots widget
  Widget _buildThinkingIndicator(dynamic character) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: character.themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(character.avatarEmoji, style: const TextStyle(fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: character.themeColor.withOpacity(0.08), width: 1),
            ),
            child: Row(
              children: [
                Text(
                  '${character.name}가 문장을 분석하고 답변을 생각 중...',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF94A1B2),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Elegant text & microphone control panel
  Widget _buildInputBar(TutorProvider provider) {
    final char = provider.activeCharacter;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Audio simulation microphone button
          IconButton(
            onPressed: () => _handleMicPressed(provider),
            icon: Icon(
              provider.isListening ? Icons.stop_circle_rounded : Icons.mic_rounded,
              color: provider.isListening ? const Color(0xFFFF4E50) : Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: provider.isListening
                  ? const Color(0xFFFF4E50).withOpacity(0.15)
                  : Colors.white.withOpacity(0.04),
              padding: const EdgeInsets.all(14),
              side: BorderSide(
                color: provider.isListening
                    ? const Color(0xFFFF4E50).withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Glassmorphic Input Textfield
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.5),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) => _handleSubmitted(text, provider),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '영어로 답변해 보세요...',
                        hintStyle: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 13.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  
                  // Sparkle AI Send button
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: IconButton(
                      onPressed: () => _handleSubmitted(_textController.text, provider),
                      icon: Icon(
                        Icons.auto_awesome_rounded,
                        color: char.themeColor,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: char.themeColor.withOpacity(0.12),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reset confirmation dialogue
  void _showResetConfirmDialog(BuildContext context, TutorProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161623),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          title: Text(
            '대화 내역 초기화',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            '이 튜터와의 모든 영어 대화 내역 및 문법 첨삭 기록을 지우고 처음부터 다시 대화를 시작하겠습니까?',
            style: GoogleFonts.outfit(color: const Color(0xFF94A1B2), fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: GoogleFonts.outfit(color: const Color(0xFF94A1B2)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.resetChat();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4E50).withOpacity(0.15),
                foregroundColor: const Color(0xFFFF4E50),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                '대화 리셋',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
