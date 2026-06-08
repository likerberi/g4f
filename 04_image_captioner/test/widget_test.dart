import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_captioner/main.dart';
import 'package:image_captioner/providers/gallery_provider.dart';

void main() {
  testWidgets('GemmaLens app smoke test', (WidgetTester tester) async {
    // Set initial mock values for SharedPreferences to avoid blocking the test environment
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame with the provider wrapped.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ],
        child: const GemmaLensApp(),
      ),
    );

    // Step through the asynchronous microtask phases of loadImages()
    await tester.pump(); // Starts loadImages and sets isLoading to true
    await tester.pump(); // Resolves SharedPreferences.getInstance()
    await tester.pump(); // Sets isLoading to false and rebuilds the tree with the empty state

    // Verify that the title 'GemmaLens' is displayed.
    expect(find.text('GemmaLens'), findsOneWidget);
    
    // Verify that the empty state placeholder button is visible.
    expect(find.text('데모 샘플 이미지 5종 가져오기'), findsOneWidget);
  });
}
