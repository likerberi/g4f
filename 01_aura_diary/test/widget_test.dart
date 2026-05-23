// This is a basic Flutter widget test for AuraDiaryApp.
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_diary/main.dart';
import 'package:provider/provider.dart';
import 'package:aura_diary/providers/diary_provider.dart';

void main() {
  testWidgets('AuraDiaryApp builds successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ],
        child: const AuraDiaryApp(),
      ),
    );

    // Verify that the title AuraDiary exists.
    expect(find.text('AuraDiary'), findsOneWidget);
  });
}
