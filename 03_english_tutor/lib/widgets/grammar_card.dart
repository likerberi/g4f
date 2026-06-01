import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';

class GrammarCard extends StatefulWidget {
  final GrammarCorrection correction;
  final Color themeColor;

  const GrammarCard({
    super.key,
    required this.correction,
    required this.themeColor,
  });

  @override
  State<GrammarCard> createState() => _GrammarCardState();
}

class _GrammarCardState extends State<GrammarCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(0.03),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.08),
                border: Border(
                  bottom: BorderSide(
                    color: widget.themeColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.offline_pin_outlined,
                    color: widget.themeColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI 실시간 첨삭 및 교정 피드백',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8E8E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Grammar',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF8E8E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original sentence (Incorrect)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFFF8E8E),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.correction.originalText,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: const Color(0xFFFF8E8E).withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Corrected sentence (Correct)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF2CB67D), // Emerald Green
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.correction.correctedText,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2CB67D),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Expandable Explanation
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(color: Color(0xFF32324D), height: 1),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: widget.themeColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.correction.explanation,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.5,
                                        color: const Color(0xFF94A1B2),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Toggle expand details button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.themeColor.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isExpanded ? '피드백 접기' : '자세한 설명 보기',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.themeColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: widget.themeColor,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
