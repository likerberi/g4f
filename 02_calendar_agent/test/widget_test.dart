import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:calendar_agent/main.dart';
import 'package:calendar_agent/providers/calendar_provider.dart';
import 'package:calendar_agent/services/ai_service.dart';

void main() {
  group('Calendar Agent Widget & Unit Tests', () {
    
    // 1. Widget Smoke Test
    testWidgets('CalendarAgentApp builds successfully smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CalendarProvider()),
          ],
          child: const CalendarAgentApp(),
        ),
      );

      // Verify that the main title exists
      expect(find.text('스마트 비서 캘린더'), findsOneWidget);
    });

    // 2. Unit Test: Mock NLP Parsing
    test('NLP Parser resolves relative date "내일"', () async {
      final aiService = AiService();
      
      // Let's test with custom input
      final event = await aiService.parseEvent('내일 오후 3시 강남역 미팅');
      
      // Verify parsed output
      expect(event.title, contains('미팅'));
      expect(event.location, equals('강남역'));
      expect(event.time, equals('15:00'));
      
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(event.date.year, equals(tomorrow.year));
      expect(event.date.month, equals(tomorrow.month));
      expect(event.date.day, equals(tomorrow.day));
    });

    test('NLP Parser resolves "오전 10시 반 코엑스 세미나"', () async {
      final aiService = AiService();
      
      final event = await aiService.parseEvent('오늘 오전 10시 반 코엑스 세미나');
      
      expect(event.title, contains('세미나'));
      expect(event.location, equals('코엑스'));
      expect(event.time, equals('10:30'));
    });
  });
}
