import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/style_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StyleProvider()),
      ],
      child: const GemmaStyleApp(),
    ),
  );
}

class GemmaStyleApp extends StatelessWidget {
  const GemmaStyleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemmaStyle - AI 톤앤매너 텍스트 마스터',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Force beautiful dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07070F), // Deep cosmic black
        primaryColor: const Color(0xFF7F5AF0), // Glowing Violet
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7F5AF0),
          secondary: Color(0xFFF15BB5), // Hot pink accent
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
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF7F5AF0),
          inactiveTrackColor: Colors.white.withOpacity(0.1),
          thumbColor: const Color(0xFFF15BB5),
          overlayColor: const Color(0xFF7F5AF0).withOpacity(0.2),
          valueIndicatorColor: const Color(0xFF7F5AF0),
          valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
