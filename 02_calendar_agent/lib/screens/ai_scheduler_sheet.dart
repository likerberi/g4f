import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_provider.dart';

class AiSchedulerSheet extends StatefulWidget {
  const AiSchedulerSheet({super.key});

  @override
  State<AiSchedulerSheet> createState() => _AiSchedulerSheetState();
}

class _AiSchedulerSheetState extends State<AiSchedulerSheet> {
  final TextEditingController _inputController = TextEditingController();
  final List<String> _suggestions = [
    '내일 오전 10시 강남역 미팅',
    '이번주 금요일 저녁 7시 홍대 약속',
    '오늘 오후 2시 대회의실 기술 세미나',
    '다음주 월요일 9시 피티 운동',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Handle analysis submission
  void _submitAnalysis(CalendarProvider provider) async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    await provider.parseNaturalLanguage(text);
  }

  // Pick Date for the suggested event
  Future<void> _selectDate(BuildContext context, CalendarProvider provider) async {
    final lastEvent = provider.lastParsedEvent;
    if (lastEvent == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastEvent.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7F5AF0),
              onPrimary: Colors.white,
              surface: Color(0xFF161623),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != lastEvent.date) {
      provider.updateLastParsedEvent(date: picked);
    }
  }

  // Pick Time for the suggested event
  Future<void> _selectTime(BuildContext context, CalendarProvider provider) async {
    final lastEvent = provider.lastParsedEvent;
    if (lastEvent == null) return;

    // Parse time
    int hour = 12;
    int minute = 0;
    try {
      final parts = lastEvent.time.split(':');
      if (parts.length == 2) {
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      }
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7F5AF0),
              onPrimary: Colors.white,
              surface: Color(0xFF161623),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      provider.updateLastParsedEvent(time: formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context);
    final isParsing = provider.isLoading;
    final parsedEvent = provider.lastParsedEvent;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF12121E), // Premium deep surface
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7F5AF0),
            blurRadius: 20,
            spreadRadius: -10,
          )
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F5AF0).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF7F5AF0),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI 일정 자동 파싱 비서',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (parsedEvent == null && !isParsing) ...[
                // Input Prompt Text Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _inputController,
                    maxLines: 3,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '예: 내일 오후 3시 강남역 스타벅스에서 개발 미팅 진행해줘',
                      hintStyle: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 14),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _submitAnalysis(provider),
                  ),
                ),
                const SizedBox(height: 16),

                // Suggestions Chips List
                Text(
                  '💡 추천 입력 스타일',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A1B2),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(
                        suggestion,
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      onPressed: () {
                        setState(() {
                          _inputController.text = suggestion;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Submit Action Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F5AF0), Color(0xFF8B5CF6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7F5AF0).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _submitAnalysis(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'AI 분석 요청',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else if (isParsing) ...[
                // Loading view with custom animations
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // pulsing glow loader
                        const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7F5AF0)),
                            backgroundColor: Color(0xFF161623),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Gemma 4 일정 분석 중...',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '상대 시간 계산 및 매개변수를 스마트하게 추출하는 중입니다.',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFF94A1B2),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              ] else if (parsedEvent != null) ...[
                // Parsing Result Cards (Visual confirmation sheet)
                Text(
                  '💡 추출 완료! 세부 사항을 확인하고 완료하세요.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2CB67D), // neon green success
                  ),
                ),
                const SizedBox(height: 16),

                // Glassmorphic Result Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF2CB67D).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Editable Title Field
                      _buildResultItem(
                        icon: Icons.title_rounded,
                        color: const Color(0xFF7F5AF0),
                        label: '일정 제목',
                        value: parsedEvent.title,
                        onEdit: () {
                          _showEditDialog(
                            context: context,
                            title: '일정 제목 수정',
                            initialValue: parsedEvent.title,
                            onSave: (val) => provider.updateLastParsedEvent(title: val),
                          );
                        },
                      ),
                      const Divider(color: Colors.white12, height: 24),

                      // Date Row
                      _buildResultItem(
                        icon: Icons.calendar_today_rounded,
                        color: const Color(0xFF00E5FF),
                        label: '날짜',
                        value: DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(parsedEvent.date),
                        onEdit: () => _selectDate(context, provider),
                      ),
                      const Divider(color: Colors.white12, height: 24),

                      // Time Row
                      _buildResultItem(
                        icon: Icons.access_time_filled_rounded,
                        color: const Color(0xFFFFF3BF),
                        label: '시간',
                        value: parsedEvent.time,
                        onEdit: () => _selectTime(context, provider),
                      ),
                      const Divider(color: Colors.white12, height: 24),

                      // Location Row
                      _buildResultItem(
                        icon: Icons.location_on_rounded,
                        color: const Color(0xFFFFC9C9),
                        label: '장소',
                        value: parsedEvent.location.isNotEmpty ? parsedEvent.location : '장소 미지정',
                        onEdit: () {
                          _showEditDialog(
                            context: context,
                            title: '장소 수정',
                            initialValue: parsedEvent.location,
                            onSave: (val) => provider.updateLastParsedEvent(location: val),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions: Add or Cancel/Retry
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          provider.clearSuggestedEvent();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF94A1B2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          '다시 작성',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2CB67D), Color(0xFF00E5FF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2CB67D).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            await provider.confirmLastParsedEvent();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                                      const SizedBox(width: 10),
                                      Text(
                                        '달력에 일정이 성공적으로 등록되었습니다.',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF2CB67D),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            '캘린더 추가',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: const Color(0xFF94A1B2),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.04),
          ),
        ),
      ],
    );
  }

  // Quick dialog to edit text fields
  void _showEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161623),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: controller,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: GoogleFonts.outfit(color: const Color(0xFF94A1B2))),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F5AF0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('저장', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
