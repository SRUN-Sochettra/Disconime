import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:anime_discovery/theme/app_theme.dart';
import 'package:anime_discovery/screens/main_screen.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/favorites_provider.dart';
import 'package:anime_discovery/providers/search_history_provider.dart';
import 'package:anime_discovery/providers/theme_provider.dart';
import 'package:anime_discovery/widgets/global_error_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env safely — ApiService has a fallback base URL if missing.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[main] .env not found or failed to load: $e');
  }

  // Load persisted user preferences before runApp so the correct
  // values are applied on the very first frame with no flash.
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  final searchHistoryProvider = SearchHistoryProvider();
  await searchHistoryProvider.loadHistory();

  // GlobalErrorHandler.run replaces runApp and installs:
  // - FlutterError.onError  → framework / widget tree errors
  // - ErrorWidget.builder   → replaces red screen with clean UI
  // The optional onError callback is where you would plug in
  // Sentry, Firebase Crashlytics, etc.
  GlobalErrorHandler.run(
    app: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AnimeProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: searchHistoryProvider),
      ],
      child: const ApiReaderApp(),
    ),
    // Uncomment and replace with your crash reporter:
    // onError: (error, stack) => Sentry.captureException(
    //   error,
    //   stackTrace: stack,
    // ),
  );
}

class ApiReaderApp extends StatelessWidget {
  final ThemeData? theme;
  final ThemeData? darkTheme;

  const ApiReaderApp({
    super.key,
    this.theme,
    this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Disconime',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: theme ?? AppTheme.light,
      darkTheme: darkTheme ?? AppTheme.dark,
      // ── Builder wraps every route in an AsyncErrorBoundary ──
      // This means any unhandled async error inside any screen
      // shows the clean fallback UI instead of crashing the app.
      builder: (context, child) {
        return AsyncErrorBoundary(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainScreen(),
    );
  }
}