import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/tutor_character.dart';
import '../providers/tutor_provider.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class CharacterSelectScreen extends StatelessWidget {
  const CharacterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TutorProvider>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background cosmic deep space gradient
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Top Bar with Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Gemma 4',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00E5FF),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  'ON-DEVICE LLM',
                                  style: GoogleFonts.outfit(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00E5FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI 영어 회화 튜터',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 28),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.04),
                          padding: const EdgeInsets.all(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Introduction card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  child: Text(
                    '지하철이나 비행기 모드에서도 작동하는 오프라인 1:1 영어 메이트! 원하는 튜터를 선택해 상황에 맞는 회화를 시작하세요.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF94A1B2),
                      height: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Tutor Characters grid / list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: TutorCharacter.defaultCharacters.length,
                    itemBuilder: (context, index) {
                      final character = TutorCharacter.defaultCharacters[index];
                      return _buildCharacterCard(context, character, provider);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Beautiful glowing tutor selector card
  Widget _buildCharacterCard(BuildContext context, TutorCharacter character, TutorProvider provider) {
    // Get custom tag labels
    List<String> tags = [];
    if (character.id == 'sophia') tags = ['친근함', '미국 발음', '일상 프리토킹'];
    if (character.id == 'liam') tags = ['격식체', '영국 런던', '비즈니스 & PT'];
    if (character.id == 'chloe') tags = ['생생함', '상황극', '여행 시뮬레이터'];
    if (character.id == 'oliver') tags = ['엄격함', 'IELTS 채점관', '학술적 오류교정'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: character.themeColor.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: character.themeColor.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () async {
            await provider.selectCharacter(character);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            }
          },
          splashColor: character.themeColor.withOpacity(0.06),
          highlightColor: character.themeColor.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Elegant Glowing Avatar Badge
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: character.themeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: character.themeColor.withOpacity(0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: character.themeColor.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Text(
                    character.avatarEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 18),

                // Character details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            character.name,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: character.themeColor,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        character.role,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: character.themeColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        character.description,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          color: const Color(0xFF94A1B2),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Hash tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: character.themeColor.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: character.themeColor.withOpacity(0.15),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '# $tag',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: character.themeColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
