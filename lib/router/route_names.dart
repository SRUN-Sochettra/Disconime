/// Centralised route name constants.
/// Use these instead of raw strings everywhere.
abstract class RouteNames {
  // ── Shell tabs ────────────────────────────────────────────────
  static const String home = '/';
  static const String search = '/search';
  static const String seasonal = '/seasonal';
  static const String genres = '/genres';
  static const String schedule = '/schedule';
  static const String characters = '/characters';
  static const String favorites = '/favorites';
  static const String statistics = '/statistics';
  static const String about = '/about';

  // ── Detail screens (pushed on top of shell) ───────────────────
  static const String animeDetail = '/anime/:malId';
  static const String genreDetail = '/genres/:genreId';
  static const String characterDetail = '/characters/:malId';

  // ── Helpers ───────────────────────────────────────────────────
  /// Builds the anime detail path for a given [malId].
  static String animeDetailPath(int malId) => '/anime/$malId';

  /// Builds the genre detail path for a given [genreId].
  static String genreDetailPath(int genreId) => '/genres/$genreId';

  /// Builds the character detail path for a given [malId].
  static String characterDetailPath(int malId) => '/characters/$malId';
}