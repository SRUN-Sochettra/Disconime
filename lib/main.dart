import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:anime_discovery/theme/app_theme.dart';
import 'package:anime_discovery/screens/main_screen.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/favorites_provider.dart';
import 'package:anime_discovery/providers/search_history_provider.dart';
import 'package:anime_discovery/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env safely — ApiService has a fallback base URL if missing.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[main] .env not found or failed to load: $e');
  }

  // FIX: ThemeProvider now persists the user's choice. Load it
  // before runApp so the correct theme is applied on first frame.
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  final searchHistoryProvider = SearchHistoryProvider();
  await searchHistoryProvider.loadHistory();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AnimeProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: searchHistoryProvider),
      ],
      child: const ApiReaderApp(),
    ),
  );
}

class ApiReaderApp extends StatelessWidget {
  const ApiReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Disconime',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainScreen(),
    );
  }
}