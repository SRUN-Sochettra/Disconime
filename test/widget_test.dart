import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anime_discovery/main.dart';
import 'package:anime_discovery/providers/theme_provider.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/favorites_provider.dart';
import 'package:anime_discovery/providers/search_history_provider.dart';

void main() {
  setUpAll(() async {
    // Initializing dotenv with mergeWith for testing
    await dotenv.load(mergeWith: {'JIKAN_API_URL': 'https://api.jikan.moe/v4'});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AnimeProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => SearchHistoryProvider()),
        ],
        child: const ApiReaderApp(),
      ),
    );
    
    // Initial pump
    await tester.pump();
    
    // ApiService uses Timers for throttling and retries.
    // We need to run these timers or they will cause "Timer still pending" errors.
    // Using runAsync allows real timers and background work to complete.
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 2));
    });

    // Final pump to settle the UI
    await tester.pumpAndSettle();
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}