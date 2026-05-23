import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _diaryController = TextEditingController();

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  // Parse hex color from model
  Color _parseColor(String hex, {double opacity = 1.0}) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16)).withOpacity(opacity);
    } catch (_) {
      return Colors.white.withOpacity(opacity);
    }
  }

  // Get matching icon for sentiment
  String _getSentimentEmoji(String sentiment) {
    switch (sentiment) {
      case '기쁨':
        return '☀️';
      case '슬픔':
        return '☔';
      case '분노':
        return '⚡';
      case '평온':
        return '🍃';
      case '설렘':
        return '🌸';
      default:
        return '💭';
    }
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Cosmic Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0B26), // Cosmic deep purple
                  Color(0xFF07070F), // Absolute deep black
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 2. Subtle glowing background auras
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7F5AF0).withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF15BB5).withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          // 3. Scrollable App Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar with AuraDiary Logo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AuraDiary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      Color(0xFF7F5AF0),
                                      Color(0xFFF15BB5),
                                    ],
                                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Gemma 4가 어루만지는 오프라인 마음 일기',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF72757A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Settings Button with Glass Effect
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Diary Entry Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (diaryProvider.currentAnalysisResult == null) ...[
                          // Diary write intro
                          Text(
                            '오늘 당신의 하루는 어땠나요?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Glassmorphic Input Text Area
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161623).withOpacity(0.65),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _diaryController,
                              maxLines: 8,
                              maxLength: 1000,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: '오늘 있었던 일과 느꼈던 마음을 편안하게 적어보세요. 최소 한두 문장 이상 작성해 주시면 더욱 정교하게 분석합니다.',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                contentPadding: const EdgeInsets.all(24),
                                border: InputBorder.none,
                                counterStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.25),
                                  fontSize: 12,
                                ),
                              ),
                              onChanged: (text) => setState(() {}),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Premium Electric Violet Gradient Button
                          GestureDetector(
                            onTap: diaryProvider.isLoading || _diaryController.text.trim().isEmpty
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    final content = _diaryController.text;
                                    final result = await diaryProvider.analyzeAndAddEntry(content);
                                    if (result != null) {
                                      _diaryController.clear();
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: _diaryController.text.trim().isEmpty
                                    ? LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.05),
                                          Colors.white.withOpacity(0.08),
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF7F5AF0), // Electric purple
                                          Color(0xFF9D4EDD), // Bright violet
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _diaryController.text.trim().isEmpty
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF7F5AF0).withOpacity(0.35),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                              ),
                              alignment: Alignment.center,
                              child: diaryProvider.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_rounded,
                                          color: _diaryController.text.trim().isEmpty
                                              ? Colors.white.withOpacity(0.25)
                                              : Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '마음 일기 분석하기',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _diaryController.text.trim().isEmpty
                                                ? Colors.white.withOpacity(0.25)
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (diaryProvider.isLoading) ...[
                            const SizedBox(height: 24),
                            // Shimmer/Animated Loading Info
                            Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    'Gemma 4가 당신의 감정(Aura)을 깊이 분석하고 있습니다...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF7F5AF0).withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '로컬 인공지능이 동작 중이니 잠시만 기다려주세요',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          // AI Analysis Results view
                          _buildAnalysisCard(diaryProvider.currentAnalysisResult!, diaryProvider),
                        ],
                      ],
                    ),
                  ),
                ),

                // History Entries Divider
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          '지나온 감정의 기록들',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${diaryProvider.entries.length}개',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Empty state or Historical List View
                if (diaryProvider.entries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 48,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '기록된 일기가 아직 없습니다.\n오늘의 감정을 첫 번째로 일기에 적어보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = diaryProvider.entries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildHistoryCard(entry, diaryProvider),
                          );
                        },
                        childCount: diaryProvider.entries.length,
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

  // Beautiful AI Result Card with Glowing border depending on parsed Sentiment Color
  Widget _buildAnalysisCard(DiaryEntry entry, DiaryProvider provider) {
    final auraColor = _parseColor(entry.sentimentColorHex);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161623).withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: auraColor.withOpacity(0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: auraColor.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Sentiment Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: auraColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: auraColor.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getSentimentEmoji(entry.sentiment),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.sentiment,
                            style: TextStyle(
                              color: auraColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '의 Aura 감지',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => provider.clearCurrentResult(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // User Diary Quote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, color: auraColor.withOpacity(0.4), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Gemma Empathetic Reply
            const Row(
              children: [
                Icon(Icons.favorite_rounded, color: Color(0xFFF15BB5), size: 18),
                SizedBox(width: 8),
                Text(
                  'Gemma 4의 공감 답장',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.replyText,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFECEFF4),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            // Actionable Advice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0B26).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: auraColor, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        '마음 건강 행동 가이드',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.advice,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF94A1B2),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Reset Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => provider.clearCurrentResult(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: const Text(
                  '새로운 마음 일기 쓰기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Beautiful History List Item Card
  Widget _buildHistoryCard(DiaryEntry entry, DiaryProvider provider) {
    final auraColor = _parseColor(entry.sentimentColorHex);
    final dateStr = '${entry.date.year}.${entry.date.month}.${entry.date.day}';

    return GestureDetector(
      onTap: () => _showDetailsBottomSheet(context, entry, provider),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161623).withOpacity(0.55),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: auraColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: auraColor.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _getSentimentEmoji(entry.sentiment),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.sentiment,
                              style: TextStyle(
                                color: auraColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.25), size: 20),
                    onPressed: () {
                      // Confirm dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF161623),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white.withOpacity(0.08)),
                          ),
                          title: const Text('기록 삭제'),
                          content: const Text('정말로 이 일기 기록을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              child: const Text('취소', style: TextStyle(color: Colors.white54)),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text('삭제', style: TextStyle(color: Color(0xFFFF4E50))),
                              onPressed: () {
                                provider.deleteEntry(entry.id);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Empathetic response preview snippet
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.03),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, color: auraColor, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.replyText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Detailed view of a past entry inside a spectacular Bottom Sheet
  void _showDetailsBottomSheet(BuildContext context, DiaryEntry entry, DiaryProvider provider) {
    final auraColor = _parseColor(entry.sentimentColorHex);
    final dateStr = '${entry.date.year}년 ${entry.date.month}월 ${entry.date.day}일';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0B26),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Stack(
            children: [
              // Bottom sheet background glowing blur
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withOpacity(0.08),
                        blurRadius: 80,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Sheet top pill indicator
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sheet Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '그날의 Aura 기록',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: auraColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: auraColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getSentimentEmoji(entry.sentiment),
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                entry.sentiment,
                                style: TextStyle(
                                  color: auraColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.06), height: 1),
                  // Sheet content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Original text
                          const Text(
                            '내가 쓴 내용',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                              ),
                            ),
                            child: Text(
                              entry.content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // 2. Empathetic response
                          Row(
                            children: [
                              const Icon(Icons.favorite_rounded, color: Color(0xFFF15BB5), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Gemma 4의 감동 답장',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.replyText,
                            style: const TextStyle(
                              color: Color(0xFFECEFF4),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // 3. Health Guide
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161623),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline_rounded, color: auraColor, size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '마음 건강 추천 가이드',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.advice,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A1B2),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
