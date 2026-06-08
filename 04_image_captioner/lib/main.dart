import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/gallery_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
      ],
      child: const GemmaLensApp(),
    ),
  );
}

class GemmaLensApp extends StatelessWidget {
  const GemmaLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemmaLens - AI 스마트 이미지 갤러리',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Force beautiful dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07070F), // Deep cosmic black
        primaryColor: const Color(0xFF7F5AF0), // Glowing Violet
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7F5AF0),
          secondary: Color(0xFF2CB67D), // Emerald accent
          surface: Color(0xFF161623), // Deep glass card base
          error: Color(0xFFFF4E50),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          titleLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.outfit(
            fontSize: 15,
            color: const Color(0xFF94A1B2),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF161623),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
