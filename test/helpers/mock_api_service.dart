import 'package:anime_discovery/models/anime_model.dart';
import 'package:anime_discovery/models/character_model.dart';
import 'package:anime_discovery/models/schedule_model.dart';
import 'package:anime_discovery/services/api_service.dart';
import 'test_data.dart';

/// A manual mock of [ApiService] — no code generation needed.
class MockApiService implements ApiService {
  // ── Control flags ─────────────────────────────────────────────
  bool shouldThrow = false;
  String throwMessage = 'Mock error';
  bool returnEmpty = false;

  // ── Call counters ─────────────────────────────────────────────
  int getTopAnimeCallCount = 0;
  int searchAnimeCallCount = 0;
  int getAnimeDetailsCallCount = 0;
  int getAnimeCharactersCallCount = 0;
  int getAnimeStaffCallCount = 0;
  int getAnimeRecommendationsCallCount = 0;
  int getSeasonNowCallCount = 0;
  int getSeasonCallCount = 0;
  int getGenresCallCount = 0;
  int getAnimeByGenreCallCount = 0;
  int getScheduleCallCount = 0;
  int getTopCharactersCallCount = 0;
  int getCharacterDetailCallCount = 0;

  // ── Captured params (for assertion in tests) ──────────────────
  String? lastSearchQuery;
  String? lastSearchType;
  String? lastSearchStatus;
  String? lastSearchRating;
  String? lastSearchOrderBy;
  String? lastSearchSort;

  void reset() {
    shouldThrow = false;
    returnEmpty = false;
    getTopAnimeCallCount = 0;
    searchAnimeCallCount = 0;
    getAnimeDetailsCallCount = 0;
    getAnimeCharactersCallCount = 0;
    getAnimeStaffCallCount = 0;
    getAnimeRecommendationsCallCount = 0;
    getSeasonNowCallCount = 0;
    getSeasonCallCount = 0;
    getGenresCallCount = 0;
    getAnimeByGenreCallCount = 0;
    getScheduleCallCount = 0;
    getTopCharactersCallCount = 0;
    getCharacterDetailCallCount = 0;
    lastSearchQuery = null;
    lastSearchType = null;
    lastSearchStatus = null;
    lastSearchRating = null;
    lastSearchOrderBy = null;
    lastSearchSort = null;
  }

  void _maybeThrow() {
    if (shouldThrow) throw Exception(throwMessage);
  }

  // ── Implementations ───────────────────────────────────────────
  @override
  Future<List<Anime>> getTopAnime({
    int page = 1,
    String? type,
    String? filter,
    String? rating,
    String? orderBy,
    String? sort,
  }) async {
    _maybeThrow();
    getTopAnimeCallCount++;
    if (returnEmpty) return [];
    return TestData.animeList;
  }

  @override
  Future<List<Anime>> searchAnime(
      String query, {
        int page = 1,
        String? type,
        String? status,
        String? rating,
        String? orderBy,
        String? sort,
      }) async {
    _maybeThrow();
    searchAnimeCallCount++;
    // Capture params so tests can assert what was passed.
    lastSearchQuery = query;
    lastSearchType = type;
    lastSearchStatus = status;
    lastSearchRating = rating;
    lastSearchOrderBy = orderBy;
    lastSearchSort = sort;
    if (returnEmpty) return [];
    return TestData.animeList
        .where((a) => a.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<Anime> getAnimeDetails(int id) async {
    _maybeThrow();
    getAnimeDetailsCallCount++;
    return TestData.naruto;
  }

  @override
  Future<List<AnimeCharacter>> getAnimeCharacters(int malId) async {
    _maybeThrow();
    getAnimeCharactersCallCount++;
    if (returnEmpty) return [];
    return [AnimeCharacter.fromJson(TestData.characterJson)];
  }

  @override
  Future<List<AnimeStaff>> getAnimeStaff(int malId) async {
    _maybeThrow();
    getAnimeStaffCallCount++;
    return [];
  }

  @override
  Future<List<Anime>> getAnimeRecommendations(int malId) async {
    _maybeThrow();
    getAnimeRecommendationsCallCount++;
    if (returnEmpty) return [];
    return [TestData.fmab];
  }

  @override
  Future<List<Anime>> getSeasonNow({int page = 1}) async {
    _maybeThrow();
    getSeasonNowCallCount++;
    if (returnEmpty) return [];
    return TestData.animeList;
  }

  @override
  Future<List<Anime>> getSeason(
      int year,
      String season, {
        int page = 1,
      }) async {
    _maybeThrow();
    getSeasonCallCount++;
    if (returnEmpty) return [];
    return TestData.animeList;
  }

  @override
  Future<List<Map<String, dynamic>>> getGenres() async {
    _maybeThrow();
    getGenresCallCount++;
    if (returnEmpty) return [];
    return [TestData.genreJson];
  }

  @override
  Future<List<Anime>> getAnimeByGenre(int genreId, {int page = 1}) async {
    _maybeThrow();
    getAnimeByGenreCallCount++;
    if (returnEmpty) return [];
    return TestData.animeList;
  }

  @override
  Future<List<ScheduleEntry>> getSchedule(
      BroadcastDay day, {
        int page = 1,
      }) async {
    _maybeThrow();
    getScheduleCallCount++;
    if (returnEmpty) return [];
    return [ScheduleEntry.fromJson(TestData.scheduleEntryJson)];
  }

  @override
  Future<List<TopCharacter>> getTopCharacters({int page = 1}) async {
    _maybeThrow();
    getTopCharactersCallCount++;
    if (returnEmpty) return [];
    // topCharacterJson uses the correct root-level structure
    return [TopCharacter.fromJson(TestData.topCharacterJson)];
  }

  @override
  Future<Character> getCharacterDetail(int malId) async {
    _maybeThrow();
    getCharacterDetailCallCount++;
    return Character.fromJson({
      ...TestData.characterJson['character'] as Map<String, dynamic>,
      'favorites': TestData.characterJson['favorites'],
      'anime': [],
      'voices': [],
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}