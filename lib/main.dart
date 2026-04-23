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

TextTheme _buildTextTheme(TextTheme base, Color color) {
  return GoogleFonts.interTextTheme(base).copyWith(
    displayLarge: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    headlineSmall: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    titleSmall: GoogleFonts.spaceMono(color: color, fontWeight: FontWeight.bold),
    labelLarge: GoogleFonts.spaceMono(color: color),
    labelMedium: GoogleFonts.spaceMono(color: color),
    labelSmall: GoogleFonts.spaceMono(color: color),
    bodyLarge: GoogleFonts.inter(color: color),
    bodyMedium: GoogleFonts.inter(color: color),
    bodySmall: GoogleFonts.inter(color: color),
  );
}

class ApiReaderApp extends StatelessWidget {
  const ApiReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightColor = const Color(0xFF1F2937);
    final darkColor = const Color(0xFFFAFAFA);
    final darkPrimary = const Color(0xFFFF4B4B);

    return MaterialApp(
      title: 'Disconime',
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
          titleTextStyle: GoogleFonts.spaceMono(
            color: const Color(0xFFFAFAFA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
        textTheme: _buildTextTheme(ThemeData.light().textTheme, lightColor),
        primaryTextTheme: _buildTextTheme(ThemeData.light().primaryTextTheme, lightColor),
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
          titleTextStyle: GoogleFonts.spaceMono(
            color: const Color(0xFFFF4B4B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
        textTheme: _buildTextTheme(ThemeData.dark().textTheme, darkColor).copyWith(
          titleLarge: GoogleFonts.spaceMono(color: darkPrimary, fontWeight: FontWeight.bold),
          titleMedium: GoogleFonts.spaceMono(color: darkPrimary, fontWeight: FontWeight.bold),
          titleSmall: GoogleFonts.spaceMono(color: darkPrimary, fontWeight: FontWeight.bold),
          labelLarge: GoogleFonts.spaceMono(color: darkPrimary),
          labelMedium: GoogleFonts.spaceMono(color: darkPrimary),
          labelSmall: GoogleFonts.spaceMono(color: darkPrimary),
        ),
        primaryTextTheme: _buildTextTheme(ThemeData.dark().primaryTextTheme, darkColor),
      ),
      home: const MainScreen(),
    );
  }
}