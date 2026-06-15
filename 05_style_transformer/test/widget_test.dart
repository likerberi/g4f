import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_transformer/main.dart';
import 'package:style_transformer/providers/style_provider.dart';
import 'package:style_transformer/screens/home_screen.dart';

void main() {
  testWidgets('GemmaStyle App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame with the provider wrapped.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StyleProvider()),
        ],
        child: const GemmaStyleApp(),
      ),
    );

    // Verify that our app displays the main screen title
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
