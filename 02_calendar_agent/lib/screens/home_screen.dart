import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_provider.dart';
import '../models/calendar_event.dart';
import 'ai_scheduler_sheet.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Open the AI Scheduler bottom sheet
  void _openAiScheduler() {
    // Clear out any stale AI result before opening sheet
    Provider.of<CalendarProvider>(context, listen: false).clearSuggestedEvent();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiSchedulerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context);
    final selectedDayEvents = provider.getEventsForDay(_selectedDay);

    return Scaffold(
      body: Stack(
        children: [
          // Background deep space gradient
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
                // Top Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3), width: 0.5),
                                ),
                                child: Text(
                                  'CALENDAR AGENT',
                                  style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '스마트 비서 캘린더',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
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

                // Calendar View Container with Glassmorphism
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7F5AF0).withOpacity(0.05),
                          blurRadius: 24,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: TableCalendar(
                      locale: 'ko_KR',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: (day) {
                        return provider.getEventsForDay(day);
                      },
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.outfit(color: const Color(0xFF94A1B2), fontWeight: FontWeight.bold, fontSize: 12),
                        weekendStyle: GoogleFonts.outfit(color: const Color(0xFFFF8E8E), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        formatButtonDecoration: BoxDecoration(
                          color: const Color(0xFF7F5AF0).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF7F5AF0).withOpacity(0.3), width: 1),
                        ),
                        formatButtonTextStyle: GoogleFonts.outfit(
                          color: const Color(0xFF7F5AF0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        titleCentered: true,
                        titleTextStyle: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                        rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                        weekendTextStyle: GoogleFonts.outfit(color: const Color(0xFFFF8E8E), fontSize: 14),
                        outsideDaysVisible: false,
                        // Today styling
                        todayDecoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF7F5AF0).withOpacity(0.5), width: 1),
                        ),
                        todayTextStyle: GoogleFonts.outfit(
                          color: const Color(0xFF7F5AF0),
                          fontWeight: FontWeight.bold,
                        ),
                        // Selected Day styling with Glow
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF7F5AF0),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF7F5AF0),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        selectedTextStyle: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        // Custom Marker builder for events
                        markerSize: 5.0,
                        markersAnchor: 2.2,
                        markersAlignment: Alignment.bottomCenter,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: events.take(3).map((e) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00E5FF), // cyan glowing dots
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00E5FF),
                                        blurRadius: 4,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Selected Date Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(_selectedDay),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '일정 ${selectedDayEvents.length}개',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A1B2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Events List View or Empty View
                Expanded(
                  child: selectedDayEvents.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          itemCount: selectedDayEvents.length,
                          itemBuilder: (context, index) {
                            final event = selectedDayEvents[index];
                            return _buildEventCard(event, provider);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAiScheduler,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF7F5AF0), Color(0xFF00E5FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7F5AF0).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'AI 스마트 일정 등록',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Beautiful empty illustration or message
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 30, right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: const Color(0xFF94A1B2).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '선택한 날짜에 등록된 일정이 없습니다.',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF94A1B2),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '아래 버튼을 눌러 Gemma 4 AI 비서에게 자연어로 편하게 일정을 말해 보세요! 알아서 쪼개어 등록해 드립니다.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Elegant event display card
  Widget _buildEventCard(CalendarEvent event, CalendarProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Dismissible(
          key: Key(event.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            await provider.deleteEvent(event.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${event.title} 일정이 삭제되었습니다.'),
                  backgroundColor: const Color(0xFFFF4E50),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24.0),
            color: const Color(0xFFFF4E50).withOpacity(0.15),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFFF4E50),
              size: 28,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Glowing Time indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F5AF0).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF7F5AF0).withOpacity(0.3), width: 0.5),
                      ),
                      child: Text(
                        event.time,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Title and location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.location.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF94A1B2)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFF94A1B2),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event.originalText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '"${event.originalText}"',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  onPressed: () async {
                    // Show a quick confirm snackbar or delete directly
                    await provider.deleteEvent(event.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${event.title} 일정이 삭제되었습니다.'),
                          backgroundColor: const Color(0xFFFF4E50),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFFF8E8E), size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8E8E).withOpacity(0.08),
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
