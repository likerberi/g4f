import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/trip_preferences.dart';
import '../providers/planner_provider.dart';
import 'planning_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Local state for preferences
  int _duration = 3;
  String _companion = 'Couple';
  String _pace = 'Balanced';
  final List<String> _categories = ['Nature', 'Healing'];
  final List<String> _regions = ['East', 'South'];
  final TextEditingController _queryController = TextEditingController();

  final List<Map<String, dynamic>> _companionOptions = [
    {'value': 'Solo', 'label': '나홀로 여행', 'subtitle': '사색과 한적함', 'icon': Icons.person},
    {'value': 'Couple', 'label': '연인과 함께', 'subtitle': '낭만과 데이트', 'icon': Icons.favorite},
    {'value': 'Friends', 'label': '친구와 함께', 'subtitle': '추억과 액티비티', 'icon': Icons.group},
    {'value': 'Family', 'label': '가족과 함께', 'subtitle': '편안함과 자연', 'icon': Icons.family_restroom},
  ];

  final List<Map<String, dynamic>> _categoryOptions = [
    {'value': 'Nature', 'label': '자연 & 풍경', 'desc': '오름, 바다, 폭포, 한라산', 'icon': Icons.wb_sunny, 'color1': const Color(0xFF2E8B57), 'color2': const Color(0xFF3CB371)},
    {'value': 'Healing', 'label': '힐링 & 휴식', 'desc': '숲길, 정원, 족욕체험, 산책', 'icon': Icons.spa, 'color1': const Color(0xFF20B2AA), 'color2': const Color(0xFF48D1CC)},
    {'value': 'CafeFood', 'label': '맛집 & 카페', 'desc': '오션뷰 카페, 흑돼지, 먹거리 시장', 'icon': Icons.restaurant, 'color1': const Color(0xFFFF8C00), 'color2': const Color(0xFFFFA500)},
    {'value': 'Activity', 'label': '레저 & 액티비티', 'desc': '우도 전기자전거, 카약, 요트, 테마파크', 'icon': Icons.directions_bike, 'color1': const Color(0xFF4682B4), 'color2': const Color(0xFF6495ED)},
    {'value': 'Culture', 'label': '역사 & 문화', 'desc': '전통 미술관, 박물관, 민속촌, 고택', 'icon': Icons.museum, 'color1': const Color(0xFF8B008B), 'color2': const Color(0xFFBA55D3)},
  ];

  final List<Map<String, dynamic>> _regionOptions = [
    {'value': 'North', 'label': '제주 시내 & 북부', 'desc': '공항근처/동문시장/도두봉'},
    {'value': 'East', 'label': '성산 & 동부 에메랄드', 'desc': '성산일출봉/우도/비자림/함덕'},
    {'value': 'South', 'label': '서귀포 & 남부 폭포', 'desc': '천지연/올레시장/카멜리아힐'},
    {'value': 'West', 'label': '애월 & 서부 Sunset', 'desc': '협재/오설록/한담산책로/신창풍차'},
  ];

  final List<Map<String, dynamic>> _paceOptions = [
    {'value': 'Relaxed', 'label': '여유로운 페이스', 'subtitle': '하루 3곳 내외 느긋한 힐링 코스'},
    {'value': 'Balanced', 'label': '적당한 페이스', 'subtitle': '하루 4곳 내외 알차고 합리적인 코스'},
    {'value': 'Packed', 'label': '알찬 페이스', 'subtitle': '하루 5곳 내외 부지런히 둘러보는 코스'},
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submitPreferences();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitPreferences() {
    // Collect preferences
    final prefs = TripPreferences(
      duration: _duration,
      companion: _companion,
      pace: _pace,
      styleCategories: _categories,
      regionPreferences: _regions,
      shortTextQuery: _queryController.text.trim(),
    );

    // Update provider
    final provider = Provider.of<PlannerProvider>(context, listen: false);
    provider.updatePreferences(prefs);

    // Navigate to planning screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlanningScreen()),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
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
          onPressed: _currentStep > 0 ? _prevStep : () => Navigator.pop(context),
        ),
        title: Text(
          '여행 스타일 설계 (${_currentStep + 1}/$_totalSteps)',
          style: GoogleFonts.notoSansKr(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9F43).withOpacity(0.08),
                    blurRadius: 90,
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
                // Step progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9F43)),
                      minHeight: 4,
                    ),
                  ),
                ),

                // Main questionnaire body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepContent(),
                      ],
                    ),
                  ),
                ),

                // Bottom Nav buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: _prevStep,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Center(
                                child: Text(
                                  '이전 단계',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: GestureDetector(
                          onTap: _nextStep,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9F43), Color(0xFFFF5252)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5252).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _currentStep == _totalSteps - 1 ? 'AI 여행 일정 생성' : '다음 단계',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Duration & Companion
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('얼마 동안 제주에 머무르시나요?', '원하는 여행 일수를 선택하세요.'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [2, 3, 4, 5].map((day) {
            final isSelected = _duration == day;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _duration = day),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF9F43).withOpacity(0.15) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF9F43) : Colors.white.withOpacity(0.08),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$day일',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFFFFAD06) : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 36),
        _buildSectionTitle('누구와 함께 가시나요?', '동행하는 유형을 선택하면 장소를 추천할 때 가중치가 적용됩니다.'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: _companionOptions.length,
          itemBuilder: (context, index) {
            final option = _companionOptions[index];
            final isSelected = _companion == option['value'];

            return GestureDetector(
              onTap: () => setState(() => _companion = option['value']),
              child: Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF9F43).withOpacity(0.12) : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF9F43) : Colors.white.withOpacity(0.06),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      option['icon'],
                      color: isSelected ? const Color(0xFFFF9F43) : Colors.white54,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option['label'],
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option['subtitle'],
                      style: GoogleFonts.notoSansKr(
                        fontSize: 10,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 2: Travel Style Categories
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('이번 제주 여행의 테마는 무엇인가요?', '복수 선택이 가능합니다. 선택한 스타일 중심으로 일정을 기획합니다.'),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categoryOptions.length,
          itemBuilder: (context, index) {
            final option = _categoryOptions[index];
            final value = option['value'] as String;
            final isSelected = _categories.contains(value);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_categories.length > 1) {
                      _categories.remove(value);
                    }
                  } else {
                    _categories.add(value);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isSelected ? 0.06 : 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF9F43).withOpacity(0.6) : Colors.white.withOpacity(0.06),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            option['color1'] as Color,
                            option['color2'] as Color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(option['icon'] as IconData, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['label'] as String,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option['desc'] as String,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 11,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFFFF9F43),
                      onChanged: (bool? val) {
                        setState(() {
                          if (isSelected) {
                            if (_categories.length > 1) {
                              _categories.remove(value);
                            }
                          } else {
                            _categories.add(value);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 3: Preferred Regions & Pace
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('주로 어디를 여행하고 싶으신가요?', '선택한 지역의 명소를 중심으로 최적 동선을 짭니다. (중복 선택 가능)'),
        const SizedBox(height: 16),
        Column(
          children: _regionOptions.map((option) {
            final value = option['value'] as String;
            final isSelected = _regions.contains(value);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_regions.length > 1) {
                        _regions.remove(value);
                      }
                    } else {
                      _regions.add(value);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E2638) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF9F43) : Colors.white.withOpacity(0.06),
                      width: isSelected ? 1.2 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['label'],
                              style: GoogleFonts.notoSansKr(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option['desc'],
                              style: GoogleFonts.notoSansKr(
                                fontSize: 10,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isSelected,
                        activeColor: const Color(0xFFFF9F43),
                        onChanged: (val) {
                          setState(() {
                            if (isSelected) {
                              if (_regions.length > 1) {
                                _regions.remove(value);
                              }
                            } else {
                              _regions.add(value);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        _buildSectionTitle('어떤 템포의 여행을 원하시나요?', '하루에 소화하는 관광명소의 개수를 설정합니다.'),
        const SizedBox(height: 16),
        Column(
          children: _paceOptions.map((option) {
            final isSelected = _pace == option['value'];

            return GestureDetector(
              onTap: () => setState(() => _pace = option['value']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF9F43).withOpacity(0.1) : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF9F43) : Colors.white.withOpacity(0.06),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? const Color(0xFFFF9F43) : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['label'],
                            style: GoogleFonts.notoSansKr(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option['subtitle'],
                            style: GoogleFonts.notoSansKr(
                              fontSize: 11,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 4: Special Request Short Answer
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('특별한 요청 사항이 있으신가요?', '가고 싶은 특정 명소나 특별히 원하는 테마(예: "동백꽃 인생샷", "흑돼지 구이 필수", "한라산 등산 포함") 등을 써보세요. AI가 반영하여 코스를 추천합니다.'),
        const SizedBox(height: 16),
        TextField(
          controller: _queryController,
          maxLines: 5,
          maxLength: 100,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            hintText: '예: 1일차 저녁에는 꼭 흑돼지 먹거리를 가고 싶고, 조용하게 숲길 위주로 많이 걷고 싶어요.',
            hintStyle: GoogleFonts.notoSansKr(color: Colors.white24, fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF9F43)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2638).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info, color: Color(0xFFFF9F43), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '모든 단계를 완료했습니다! AI가 100개 명소를 실시간으로 연계하여 중첩 동선을 제거하고, 최적화된 하루 동선과 KakaoMap 링크가 포함된 플랜을 가시화합니다.',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.notoSansKr(
            fontSize: 12,
            color: Colors.white38,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
