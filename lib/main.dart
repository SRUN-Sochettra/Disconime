import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'providers/anime_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/search_history_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables if available.
  // If .env is missing, continue safely — ApiService already has
  // a fallback base URL.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('[main] .env not found or failed to load: $e');
  }

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  final searchHistoryProvider = SearchHistoryProvider();
  await searchHistoryProvider.loadHistory();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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