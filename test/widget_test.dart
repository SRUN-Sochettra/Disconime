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

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_discovery/services/api_service.dart';
import 'package:anime_discovery/providers/schedule_provider.dart';
import 'package:anime_discovery/providers/characters_provider.dart';
import 'package:anime_discovery/providers/connectivity_provider.dart';

void main() {
  setUpAll(() async {
    // Initializing SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
    
    // Initializing dotenv with mergeWith for testing
    await dotenv.load(mergeWith: {'JIKAN_API_URL': 'https://api.jikan.moe/v4'});
    // GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // ── Mock API responses ────────────────────────────────────
    final mockClient = MockClient((request) async {
      return http.Response(
        json.encode({'data': [], 'pagination': {'has_next_page': false}}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    
    final apiService = ApiService(client: mockClient);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AnimeProvider(apiService: apiService)),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => SearchHistoryProvider()),
          ChangeNotifierProvider(create: (_) => ScheduleProvider(apiService: apiService)),
          ChangeNotifierProvider(create: (_) => CharactersProvider(apiService: apiService)),
          ChangeNotifierProvider(create: (_) => ConnectivityProvider(initialStatus: true)),
        ],
        child: ApiReaderApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
      ),
    );
    
    // Initial pump
    await tester.pump();
    
    // Settling timers and async work
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 1));
    });

    // Final pump to settle the UI
    await tester.pumpAndSettle();
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}