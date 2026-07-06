import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attraction.dart';
import '../models/attraction_data.dart';
import '../models/itinerary.dart';
import '../providers/planner_provider.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with SingleTickerProviderStateMixin {
  int _selectedDayIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchKakaoMap(String name) async {
    final query = Uri.encodeComponent(name);
    final appUri = Uri.parse('kakaomap://search?q=$query');
    final webUri = Uri.parse('https://map.kakao.com/link/search/$query');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Nature':
        return const Color(0xFF2E8B57); // SeaGreen
      case 'Healing':
        return const Color(0xFF20B2AA); // LightSeaGreen
      case 'CafeFood':
        return const Color(0xFFFF8E53); // Orange
      case 'Activity':
        return const Color(0xFF4682B4); // SteelBlue
      case 'Culture':
        return const Color(0xFFBA55D3); // MediumOrchid
      default:
        return Colors.blueGrey;
    }
  }

  String _getCategoryKo(String category) {
    switch (category) {
      case 'Nature':
        return '자연';
      case 'Healing':
        return '힐링';
      case 'CafeFood':
        return '식당/카페';
      case 'Activity':
        return '액티비티';
      case 'Culture':
        return '역사/문화';
      default:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    final planner = Provider.of<PlannerProvider>(context);
    final itinerary = planner.itinerary;

    if (itinerary == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0E17),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final days = itinerary.days;
    final activeDay = days.isNotEmpty ? days[_selectedDayIndex] : null;

    // Get recommended attractions based on IDs
    final recommendedAttractions = jejuAttractions
        .where((a) => itinerary.recommendedAttractionIds.contains(a.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Stack(
        children: [
          // Background glows
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9F43).withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 35,
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
                    color: const Color(0xFF0D9488).withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          planner.reset();
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        '제주 AI 추천 코스',
                        style: GoogleFonts.notoSansKr(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          // Start planning again with same prefs
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Trip Title Summary Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9F43).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '테마: ${itinerary.recommendedTheme}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFAD06),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${planner.preferences.duration}일 | ${planner.preferences.companion}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        itinerary.title,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        itinerary.description,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Beautiful custom glass Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9F43), Color(0xFFFF5252)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: '일자별 일정표'),
                      Tab(text: '추천 장소 모아보기'),
                    ],
                  ),
                ),

                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: Itinerary timeline
                      Column(
                        children: [
                          // Day capsule selector
                          SizedBox(
                            height: 44,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: days.length,
                              itemBuilder: (context, index) {
                                final isSelected = _selectedDayIndex == index;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedDayIndex = index),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFF9F43).withOpacity(0.15)
                                          : Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFF9F43)
                                            : Colors.white.withOpacity(0.05),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Day ${index + 1}',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? const Color(0xFFFFAD06) : Colors.white60,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Active Day Title
                          if (activeDay != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFFFF9F43), size: 14),
                                  const SizedBox(width: 8),
                                  Text(
                                    activeDay.title,
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Timeline ListView
                          Expanded(
                            child: activeDay == null
                                ? const Center(child: Text('일정이 비어 있습니다.'))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                    itemCount: activeDay.spots.length,
                                    itemBuilder: (context, spotIndex) {
                                      final spot = activeDay.spots[spotIndex];
                                      final isLast = spotIndex == activeDay.spots.length - 1;

                                      return _buildTimelineItem(spot, isLast);
                                    },
                                  ),
                          ),
                        ],
                      ),

                      // TAB 2: Recommendations collection
                      recommendedAttractions.isEmpty
                          ? const Center(child: Text('추천 장소가 없습니다.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              itemCount: recommendedAttractions.length,
                              itemBuilder: (context, index) {
                                final attraction = recommendedAttractions[index];
                                return _buildRecommendationCard(attraction);
                              },
                            ),
                    ],
                  ),
                ),

                // Start Over Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: OutlinedButton(
                    onPressed: () {
                      planner.reset();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      '다시 코스 짜기',
                      style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold),
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

  Widget _buildTimelineItem(ItinerarySpot spot, bool isLast) {
    final attraction = spot.attraction;
    final catColor = _getCategoryColor(attraction.category);
    final catKo = _getCategoryKo(attraction.category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Timeline Indicator Column
          Column(
            children: [
              // Timeslot Capsule
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    spot.timeSlot,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Circle Node
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: catColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: catColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              // Vertical connecting line
              Expanded(
                child: isLast
                    ? const SizedBox.shrink()
                    : Container(
                        width: 2,
                        color: Colors.white.withOpacity(0.15),
                      ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Right Card & Route Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stop Main Card
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Region & Category Chip
                      Row(
                        children: [
                          Text(
                            attraction.region == 'North'
                                ? '제주북부'
                                : attraction.region == 'East'
                                    ? '제주동부'
                                    : attraction.region == 'South'
                                        ? '제주남부'
                                        : '제주서부',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white38,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              catKo,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Attraction name
                      Text(
                        attraction.koreanName,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        attraction.name,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // AI Note
                      Text(
                        spot.customNotes,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 11,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Open Map Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => _launchKakaoMap(attraction.koreanName),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE500).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFEE500).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.navigation, color: Color(0xFFFEE500), size: 12),
                                  const SizedBox(width: 6),
                                  Text(
                                    '카카오맵 길찾기',
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFEE500),
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

                // Transit/Routing visual between stops
                if (!isLast && spot.transitMinutesToNext > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, color: Color(0xFFFF9F43), size: 14),
                        const SizedBox(width: 8),
                        Text(
                          '다음 목적지까지 이동 (대략 ${spot.transitMinutesToNext}분 소요)',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Attraction attraction) {
    final catColor = _getCategoryColor(attraction.category);
    final catKo = _getCategoryKo(attraction.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left category marker
          Container(
            width: 5,
            height: 60,
            decoration: BoxDecoration(
              color: catColor,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      attraction.koreanName,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        catKo,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: catColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  attraction.description,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 11,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: attraction.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 9,
                          color: Colors.white38,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action button
          IconButton(
            icon: const Icon(Icons.navigation, color: Color(0xFFFEE500), size: 20),
            onPressed: () => _launchKakaoMap(attraction.koreanName),
          ),
        ],
      ),
    );
  }
}
