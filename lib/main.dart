import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const ApiReaderApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ApiReaderApp extends StatelessWidget {
  const ApiReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Reader',
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: const ColorScheme.light(
          surface: Color(0xFFFFFFFF),
          primary: Color(0xFFFF4B4B),
          secondary: Color(0xFFFF8A00),
          onSurface: Color(0xFF1F2937),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFF4B4B).withValues(alpha: 0.7),
          foregroundColor: const Color(0xFFFAFAFA),
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFFFFFFFF).withValues(alpha: 0.7),
          selectedItemColor: const Color(0xFFFF4B4B),
          unselectedItemColor: const Color(0xFF1F2937),
        ),
        cardTheme: const CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Color(0xFFFF4B4B), width: 1),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.inter(color: const Color(0xFF1F2937)),
          bodyMedium: GoogleFonts.inter(color: const Color(0xFF1F2937)),
          bodySmall: GoogleFonts.inter(color: const Color(0xFF1F2937)),
          titleLarge: GoogleFonts.spaceMono(color: const Color(0xFF1F2937), fontWeight: FontWeight.bold),
          titleMedium: GoogleFonts.spaceMono(color: const Color(0xFF1F2937), fontWeight: FontWeight.bold),
          titleSmall: GoogleFonts.spaceMono(color: const Color(0xFF1F2937), fontWeight: FontWeight.bold),
          labelLarge: GoogleFonts.spaceMono(color: const Color(0xFF1F2937)),
          labelMedium: GoogleFonts.spaceMono(color: const Color(0xFF1F2937)),
          labelSmall: GoogleFonts.spaceMono(color: const Color(0xFF1F2937)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1F2937),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF111827),
          primary: Color(0xFFFF4B4B),
          secondary: Color(0xFFFF8A00),
          onSurface: Color(0xFFFAFAFA),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF111827).withValues(alpha: 0.7),
          foregroundColor: const Color(0xFFFF4B4B),
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF111827).withValues(alpha: 0.7),
          selectedItemColor: const Color(0xFFFF4B4B),
          unselectedItemColor: Colors.grey,
        ),
        cardTheme: const CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Color(0xFFFF4B4B), width: 1),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.inter(color: const Color(0xFFFAFAFA)),
          bodyMedium: GoogleFonts.inter(color: const Color(0xFFFAFAFA)),
          bodySmall: GoogleFonts.inter(color: const Color(0xFFFAFAFA)),
          titleLarge: GoogleFonts.spaceMono(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
          titleMedium: GoogleFonts.spaceMono(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
          titleSmall: GoogleFonts.spaceMono(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
          labelLarge: GoogleFonts.spaceMono(color: const Color(0xFFFF4B4B)),
          labelMedium: GoogleFonts.spaceMono(color: const Color(0xFFFF4B4B)),
          labelSmall: GoogleFonts.spaceMono(color: const Color(0xFFFF4B4B)),
        ),
      ),
      home: const MainScreen(),
    );
  }
}