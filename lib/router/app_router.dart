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

/// The single [GoRouter] instance for the entire app.
///
/// Architecture:
/// - A [ShellRoute] wraps the 9 main tabs — the bottom nav bar
///   persists while navigating between tabs.
/// - Detail screens ([DetailScreen], [GenreDetailScreen],
///   [CharacterDetailScreen]) are pushed on TOP of the shell
///   so the nav bar is hidden, matching the previous behaviour.
///
/// Extra objects (full [Anime], [TopCharacter]) are passed via
/// GoRouter's `extra` parameter to avoid re-fetching data that
/// the calling screen already has.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  debugLogDiagnostics: false,
  routes: [
    // ── Shell — persistent bottom nav ─────────────────────────
    ShellRoute(
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

    // ── Anime detail — pushed on top of shell ─────────────────
    GoRoute(
      path: RouteNames.animeDetail,
      pageBuilder: (context, state) {
        final anime = state.extra as Anime?;
        final malId = int.tryParse(state.pathParameters['malId'] ?? '');
        final heroTag = state.uri.queryParameters['heroTag'];

        // If the full Anime object was passed as extra use it
        // directly. Otherwise the detail screen will fetch it.
        return _scaleFadePage(
          key: state.pageKey,
          child: DetailScreen(
            anime: anime ??
                Anime(
                  malId: malId ?? 0,
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

    // ── Genre detail — pushed on top of shell ─────────────────
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

    // ── Character detail — pushed on top of shell ─────────────
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

        // Fallback — should not happen in normal navigation flow.
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

/// No transition — used for tab switches inside the shell.
NoTransitionPage<void> _noTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: key, child: child);
}

/// Scale + fade transition — used for detail screens.
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

/// Slide transition — used for genre detail drill-down.
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