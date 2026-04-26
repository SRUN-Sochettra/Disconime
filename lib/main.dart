import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:anime_discovery/theme/app_theme.dart';
import 'package:anime_discovery/router/app_router.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/favorites_provider.dart';
import 'package:anime_discovery/providers/search_history_provider.dart';
import 'package:anime_discovery/providers/theme_provider.dart';
import 'package:anime_discovery/providers/schedule_provider.dart';
import 'package:anime_discovery/providers/characters_provider.dart';
import 'package:anime_discovery/providers/connectivity_provider.dart';
import 'package:anime_discovery/services/connectivity_service.dart';
import 'package:anime_discovery/widgets/global_error_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Limit image cache
  PaintingBinding.instance.imageCache.maximumSize = 80;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      40 * 1024 * 1024; // 40MB

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[main] .env not found or failed to load: $e');
  }

  await ConnectivityService.instance.init();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  final searchHistoryProvider = SearchHistoryProvider();
  await searchHistoryProvider.loadHistory();

  GlobalErrorHandler.run(
    app: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AnimeProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: searchHistoryProvider),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => CharactersProvider()),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(
            initialStatus: ConnectivityService.instance.isOnline,
          ),
        ),
      ],
      child: const ApiReaderApp(),
    ),
  );
}

class ApiReaderApp extends StatefulWidget {
  final ThemeData? theme;
  final ThemeData? darkTheme;

  const ApiReaderApp({
    super.key,
    this.theme,
    this.darkTheme,
  });

  @override
  State<ApiReaderApp> createState() => _ApiReaderAppState();
}

class _ApiReaderAppState extends State<ApiReaderApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // FIX: Implement lifecycle management (Issue #7)
    ConnectivityService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      ConnectivityService.instance.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Disconime',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: widget.theme ?? AppTheme.light,
      darkTheme: widget.darkTheme ?? AppTheme.dark,
      // ── GoRouter wiring ─────────────────────────────────────
      routerConfig: appRouter,
      // ── Global error boundary ────────────────────────────────
      builder: (context, child) {
        return AsyncErrorBoundary(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}