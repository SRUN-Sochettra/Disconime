import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_screen.dart';
import 'providers/anime_provider.dart';
import 'providers/favorites_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Load persisted favorites before the app renders.
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AnimeProvider()),
        // Provide the already-initialized favorites provider.
        ChangeNotifierProvider.value(value: favoritesProvider),
      ],
      child: const ApiReaderApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

TextTheme _buildTextTheme(TextTheme base, Color color) {
  return GoogleFonts.spaceMonoTextTheme(base).copyWith(
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
    bodyLarge: GoogleFonts.spaceMono(color: color),
    bodyMedium: GoogleFonts.spaceMono(color: color),
    bodySmall: GoogleFonts.spaceMono(color: color),
  );
}

class ApiReaderApp extends StatelessWidget {
  const ApiReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    const cyberCyan = Color(0xFF00E5FF);

    const darkColor = Color(0xFFE0E0E0);
    const scaffoldDark = Color(0xFF050505);
    const surfaceDark = Color(0xFF111111);

    const lightColor = Color(0xFF1A1A1A);
    const scaffoldLight = Color(0xFFF5F5F5);
    const surfaceLight = Color(0xFFFFFFFF);

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Disconime',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: scaffoldLight,
        colorScheme: ColorScheme.light(
          surface: surfaceLight,
          primary: cyberCyan,
          secondary: const Color(0xFFFF003C),
          onSurface: lightColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: scaffoldLight,
          foregroundColor: cyberCyan,
          elevation: 0,
          titleTextStyle: GoogleFonts.spaceMono(
            color: cyberCyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
          iconTheme: const IconThemeData(color: cyberCyan),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: cyberCyan,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: cyberCyan.withAlpha(128), width: 1),
          ),
        ),
        textTheme: _buildTextTheme(ThemeData.light().textTheme, lightColor),
        primaryTextTheme:
            _buildTextTheme(ThemeData.light().primaryTextTheme, lightColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: scaffoldDark,
        colorScheme: ColorScheme.dark(
          surface: surfaceDark,
          primary: cyberCyan,
          secondary: const Color(0xFFFF003C),
          onSurface: darkColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: scaffoldDark,
          foregroundColor: cyberCyan,
          elevation: 0,
          titleTextStyle: GoogleFonts.spaceMono(
            color: cyberCyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
          iconTheme: const IconThemeData(color: cyberCyan),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: cyberCyan,
          unselectedItemColor: Colors.grey[800],
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: cyberCyan.withAlpha(128), width: 1),
          ),
        ),
        textTheme: _buildTextTheme(ThemeData.dark().textTheme, darkColor),
        primaryTextTheme:
            _buildTextTheme(ThemeData.dark().primaryTextTheme, darkColor),
      ),
      home: const MainScreen(),
    );
  }
}