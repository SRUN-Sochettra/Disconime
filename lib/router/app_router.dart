import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anime_discovery/screens/home_screen.dart';
import 'package:anime_discovery/screens/search_screen.dart';
import 'package:anime_discovery/screens/seasonal_screen.dart';
import 'package:anime_discovery/screens/genres_screen.dart';
import 'package:anime_discovery/screens/schedule_screen.dart';
import 'package:anime_discovery/screens/characters_screen.dart';
import 'package:anime_discovery/screens/favorites_screen.dart';
import 'package:anime_discovery/screens/statistics_screen.dart';
import 'package:anime_discovery/screens/about_screen.dart';
import 'package:anime_discovery/screens/detail_screen.dart';
import 'package:anime_discovery/screens/genre_detail_screen.dart';
import 'package:anime_discovery/screens/character_detail_screen.dart';
import 'package:anime_discovery/screens/main_screen.dart';
import 'package:anime_discovery/models/anime_model.dart';
import 'package:anime_discovery/models/character_model.dart';
import 'route_names.dart';

// FIX: Dedicated navigator key for the shell so it is never
// disposed when switching tabs — prevents the "already disposed"
// crash and provider lookup failures mid-navigation.
final _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      // FIX: Assign the shell key
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: RouteNames.home,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.search,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const SearchScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.seasonal,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const SeasonalScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.genres,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const GenresScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.schedule,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const ScheduleScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.characters,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const CharactersScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.favorites,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const FavoritesScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.statistics,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const StatisticsScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.about,
          pageBuilder: (context, state) => _noTransitionPage(
            key: state.pageKey,
            child: const AboutScreen(),
          ),
        ),
      ],
    ),

    // ── Detail screens outside shell ───────────────────────────
    GoRoute(
      path: RouteNames.animeDetail,
      pageBuilder: (context, state) {
        final anime = state.extra as Anime?;
        final malId = int.tryParse(
          state.pathParameters['malId'] ?? '',
        );

        if (malId == null) {
          return _noTransitionPage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Invalid anime ID')),
            ),
          );
        }

        final heroTag = state.uri.queryParameters['heroTag'];

        return _scaleFadePage(
          key: state.pageKey,
          child: DetailScreen(
            anime: anime ??
                Anime(
                  malId: malId,
                  title: '',
                  imageUrl: '',
                  score: const Score(),
                  synopsis: const Synopsis(text: 'Loading...'),
                  genres: const [],
                ),
            heroTag: heroTag,
          ),
        );
      },
    ),

    GoRoute(
      path: RouteNames.genreDetail,
      pageBuilder: (context, state) {
        final genreId =
            int.tryParse(state.pathParameters['genreId'] ?? '') ?? 0;
        final genreName =
            state.uri.queryParameters['name'] ?? 'Genre';

        return _slidePage(
          key: state.pageKey,
          child: GenreDetailScreen(
            genreId: genreId,
            genreName: genreName,
          ),
        );
      },
    ),

    GoRoute(
      path: RouteNames.characterDetail,
      pageBuilder: (context, state) {
        final character = state.extra as TopCharacter?;
        final malId =
            int.tryParse(state.pathParameters['malId'] ?? '') ?? 0;
        final heroTag = state.uri.queryParameters['heroTag'];

        if (character != null) {
          return _scaleFadePage(
            key: state.pageKey,
            child: CharacterDetailScreen(
              character: character,
              heroTag: heroTag,
            ),
          );
        }

        return _scaleFadePage(
          key: state.pageKey,
          child: CharacterDetailScreen(
            character: TopCharacter(
              malId: malId,
              name: '',
              imageUrl: '',
              favorites: 0,
              animeNames: const [],
            ),
            heroTag: heroTag,
          ),
        );
      },
    ),
  ],
);

// ── Page builder helpers ──────────────────────────────────────────

NoTransitionPage<void> _noTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: key, child: child);
}

CustomTransitionPage<void> _scaleFadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeOutCubic;
      final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );
      return ScaleTransition(
        scale: scale,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

CustomTransitionPage<void> _slidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeOutCubic;
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curve));
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}