import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';
import 'package:anime_discovery/models/filter_model.dart';
import '../helpers/mock_api_service.dart';
import '../helpers/test_data.dart';

void main() {
  late AnimeProvider provider;
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
    provider = AnimeProvider(apiService: mockApi);
  });

  tearDown(() {
    provider.dispose();
    mockApi.reset();
  });

  // ── Top Anime ─────────────────────────────────────────────────
  group('fetchTopAnime', () {
    test('starts in initial state', () {
      expect(provider.topAnimeState, FetchState.initial);
      expect(provider.topAnime, isEmpty);
    });

    test('sets loaded state with results', () async {
      await provider.fetchTopAnime();
      expect(provider.topAnimeState, FetchState.loaded);
      expect(provider.topAnime, isNotEmpty);
      expect(provider.topAnime.length, TestData.animeList.length);
      expect(mockApi.getTopAnimeCallCount, 1);
    });

    test('sets error state on failure', () async {
      mockApi.shouldThrow = true;
      await provider.fetchTopAnime();
      expect(provider.topAnimeState, FetchState.error);
      expect(provider.topAnimeErrorMessage, isNotEmpty);
      expect(provider.topAnime, isEmpty);
    });

    test('clears previous results on fresh fetch', () async {
      await provider.fetchTopAnime();
      await provider.fetchTopAnime();
      expect(mockApi.getTopAnimeCallCount, 2);
      expect(provider.topAnime.length, TestData.animeList.length);
    });

    test('loads more results and appends them', () async {
      await provider.fetchTopAnime();
      final countAfterFirst = provider.topAnime.length;
      await provider.fetchTopAnime(loadMore: true);
      expect(provider.topAnime.length, countAfterFirst * 2);
      expect(provider.currentTopPage, 2);
    });

    test('does not load more when hasMore is false', () async {
      mockApi.returnEmpty = true;
      await provider.fetchTopAnime();
      expect(provider.hasMoreTopAnime, isFalse);
      mockApi.returnEmpty = false;
      await provider.fetchTopAnime(loadMore: true);
      expect(mockApi.getTopAnimeCallCount, 1);
    });

    test('sets hasMore false when empty results returned', () async {
      mockApi.returnEmpty = true;
      await provider.fetchTopAnime();
      expect(provider.hasMoreTopAnime, isFalse);
    });

    test('resets page to 1 on fresh fetch', () async {
      await provider.fetchTopAnime();
      await provider.fetchTopAnime(loadMore: true);
      expect(provider.currentTopPage, 2);
      await provider.fetchTopAnime();
      expect(provider.currentTopPage, 1);
    });
  });

  // ── Filter ────────────────────────────────────────────────────
  group('applyFilter / clearFilter', () {
    test('applyFilter sets filter and fetches', () async {
      const filter = AnimeFilter(type: 'tv');
      provider.applyFilter(filter);
      await Future.delayed(Duration.zero);
      expect(provider.currentFilter, filter);
      expect(mockApi.getTopAnimeCallCount, greaterThan(0));
    });

    test('clearFilter resets to empty and fetches', () async {
      provider.applyFilter(const AnimeFilter(type: 'tv'));
      await Future.delayed(Duration.zero);
      provider.clearFilter();
      await Future.delayed(Duration.zero);
      expect(provider.currentFilter, const AnimeFilter());
      expect(mockApi.getTopAnimeCallCount, greaterThan(1));
    });
  });

  // ── Search ────────────────────────────────────────────────────
  group('searchAnime', () {
    test('starts in initial state', () {
      expect(provider.searchState, FetchState.initial);
    });

    test('returns to initial state on empty query', () async {
      await provider.searchAnime('naruto');
      await provider.searchAnime('');
      expect(provider.searchState, FetchState.initial);
      expect(provider.searchResults, isEmpty);
    });

    test('sets loaded state with results', () async {
      await provider.searchAnime('naruto');
      expect(provider.searchState, FetchState.loaded);
      expect(provider.searchResults, isNotEmpty);
      expect(mockApi.searchAnimeCallCount, 1);
    });

    test('sets error state on failure', () async {
      mockApi.shouldThrow = true;
      await provider.searchAnime('naruto');
      expect(provider.searchState, FetchState.error);
      expect(provider.searchErrorMessage, isNotEmpty);
    });

    test('resets page when query changes', () async {
      await provider.searchAnime('naruto');
      await provider.searchAnime('naruto', loadMore: true);
      expect(provider.currentSearchPage, 2);
      await provider.searchAnime('fmab');
      expect(provider.currentSearchPage, 1);
    });

    test('does not load more when no more results', () async {
      mockApi.returnEmpty = true;
      await provider.searchAnime('naruto');
      expect(provider.hasMoreSearchResults, isFalse);
      await provider.searchAnime('naruto', loadMore: true);
      expect(mockApi.searchAnimeCallCount, 1);
    });
  });

  // ── Search filter ─────────────────────────────────────────────
  group('applySearchFilter / clearSearchFilter', () {
    test('applySearchFilter stores filter', () async {
      await provider.searchAnime('naruto');
      const filter = AnimeFilter(type: 'tv', rating: 'pg13');
      provider.applySearchFilter(filter);
      await Future.delayed(Duration.zero);
      expect(provider.searchFilter, filter);
    });

    test('applySearchFilter triggers re-search with filter params', () async {
      await provider.searchAnime('naruto');
      final firstCount = mockApi.searchAnimeCallCount;
      provider.applySearchFilter(const AnimeFilter(type: 'tv'));
      await Future.delayed(Duration.zero);
      expect(mockApi.searchAnimeCallCount, greaterThan(firstCount));
      expect(mockApi.lastSearchType, 'tv');
    });

    test('clearSearchFilter resets to empty filter', () async {
      await provider.searchAnime('naruto');
      provider.applySearchFilter(const AnimeFilter(type: 'tv'));
      await Future.delayed(Duration.zero);
      provider.clearSearchFilter();
      await Future.delayed(Duration.zero);
      expect(provider.searchFilter, const AnimeFilter());
    });

    test('applySearchFilter does not re-search when query is empty', () async {
      provider.applySearchFilter(const AnimeFilter(type: 'tv'));
      await Future.delayed(Duration.zero);
      expect(mockApi.searchAnimeCallCount, 0);
    });

    test('search passes status filter to API', () async {
      provider.applySearchFilter(const AnimeFilter(filter: 'airing'));
      await provider.searchAnime('naruto');
      expect(mockApi.lastSearchStatus, 'airing');
    });

    test('search passes rating filter to API', () async {
      provider.applySearchFilter(const AnimeFilter(rating: 'pg13'));
      await provider.searchAnime('naruto');
      expect(mockApi.lastSearchRating, 'pg13');
    });

    test('search passes orderBy and sort to API', () async {
      provider.applySearchFilter(
          const AnimeFilter(orderBy: 'score', sort: 'desc'));
      await provider.searchAnime('naruto');
      expect(mockApi.lastSearchOrderBy, 'score');
      expect(mockApi.lastSearchSort, 'desc');
    });
  });

  // ── Recommendations ───────────────────────────────────────────
  group('fetchRecommendations', () {
    test('fetches and stores recommendations', () async {
      await provider.fetchRecommendations(20);
      expect(provider.recommendationsState, FetchState.loaded);
      expect(provider.recommendations, isNotEmpty);
    });

    test('skips re-fetch for same malId when loaded', () async {
      await provider.fetchRecommendations(20);
      await provider.fetchRecommendations(20);
      expect(mockApi.getAnimeRecommendationsCallCount, 1);
    });

    test('re-fetches for different malId', () async {
      await provider.fetchRecommendations(20);
      provider.clearRecommendations();
      await provider.fetchRecommendations(5114);
      expect(mockApi.getAnimeRecommendationsCallCount, 2);
    });

    test('clearRecommendations resets state', () async {
      await provider.fetchRecommendations(20);
      provider.clearRecommendations();
      expect(provider.recommendationsState, FetchState.initial);
      expect(provider.recommendations, isEmpty);
    });
  });

  // ── Characters ────────────────────────────────────────────────
  group('fetchCharacters', () {
    test('fetches and stores characters', () async {
      await provider.fetchCharacters(20);
      expect(provider.charactersState, FetchState.loaded);
      expect(provider.characters, isNotEmpty);
    });

    test('skips re-fetch for same malId when loaded', () async {
      await provider.fetchCharacters(20);
      await provider.fetchCharacters(20);
      expect(mockApi.getAnimeCharactersCallCount, 1);
    });

    test('sets error state on failure', () async {
      mockApi.shouldThrow = true;
      await provider.fetchCharacters(20);
      expect(provider.charactersState, FetchState.error);
      expect(provider.charactersErrorMessage, isNotEmpty);
    });
  });

  // ── Staff ─────────────────────────────────────────────────────
  group('fetchStaff', () {
    test('fetches staff successfully', () async {
      await provider.fetchStaff(20);
      expect(provider.staffState, FetchState.loaded);
    });

    test('skips re-fetch for same malId', () async {
      await provider.fetchStaff(20);
      await provider.fetchStaff(20);
      expect(mockApi.getAnimeStaffCallCount, 1);
    });
  });

  // ── clearDetailData ───────────────────────────────────────────
  group('clearDetailData', () {
    test('clears all detail-related state', () async {
      await provider.fetchRecommendations(20);
      await provider.fetchCharacters(20);
      await provider.fetchStaff(20);
      provider.clearDetailData();
      expect(provider.recommendationsState, FetchState.initial);
      expect(provider.charactersState, FetchState.initial);
      expect(provider.staffState, FetchState.initial);
    });
  });

  // ── Seasonal ──────────────────────────────────────────────────
  group('fetchSeasonalAnime', () {
    test('fetches current season by default', () async {
      await provider.fetchSeasonalAnime();
      expect(provider.seasonalState, FetchState.loaded);
      expect(provider.seasonalAnime, isNotEmpty);
      expect(mockApi.getSeasonNowCallCount, 1);
    });

    test('fetches specific season when year and season provided', () async {
      await provider.fetchSeasonalAnime(year: 2020, season: 'spring');
      expect(provider.seasonalState, FetchState.loaded);
      expect(mockApi.getSeasonCallCount, 1);
      expect(mockApi.getSeasonNowCallCount, 0);
    });

    test('seasonLabel returns correct label', () async {
      await provider.fetchSeasonalAnime(year: 2020, season: 'spring');
      expect(provider.seasonLabel, 'Spring 2020');
    });

    test('seasonLabel returns Current Season when no selection', () {
      expect(provider.seasonLabel, 'Current Season');
    });

    test('resets when new season selected', () async {
      await provider.fetchSeasonalAnime(year: 2020, season: 'spring');
      await provider.fetchSeasonalAnime(
          year: 2020, season: 'spring', loadMore: true);
      expect(provider.currentSeasonalPage, 2);
      await provider.fetchSeasonalAnime(year: 2021, season: 'fall');
      expect(provider.currentSeasonalPage, 1);
    });
  });

  // ── Seasonal client-side filter ───────────────────────────────
  group('filteredSeasonalAnime / setSeasonalSort / setSeasonalTypeFilter', () {
    setUp(() async {
      await provider.fetchSeasonalAnime();
    });

    test('filteredSeasonalAnime returns all when no filter', () {
      expect(
        provider.filteredSeasonalAnime.length,
        provider.seasonalAnime.length,
      );
    });

    test('setSeasonalTypeFilter filters by type', () {
      provider.setSeasonalTypeFilter('TV');
      final filtered = provider.filteredSeasonalAnime;
      expect(filtered.every((a) => a.type?.toLowerCase() == 'tv'), isTrue);
    });

    test('setSeasonalTypeFilter null shows all', () {
      provider.setSeasonalTypeFilter('TV');
      provider.setSeasonalTypeFilter(null);
      expect(
        provider.filteredSeasonalAnime.length,
        provider.seasonalAnime.length,
      );
    });

    test('setSeasonalSort score sorts descending by score', () {
      provider.setSeasonalSort('score');
      final filtered = provider.filteredSeasonalAnime;
      for (var i = 0; i < filtered.length - 1; i++) {
        expect(
          (filtered[i].score.value ?? 0) >=
              (filtered[i + 1].score.value ?? 0),
          isTrue,
        );
      }
    });

    test('setSeasonalSort title sorts ascending by title', () {
      provider.setSeasonalSort('title');
      final filtered = provider.filteredSeasonalAnime;
      for (var i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].title.compareTo(filtered[i + 1].title) <= 0,
          isTrue,
        );
      }
    });

    test('notifies listeners on setSeasonalSort', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.setSeasonalSort('title');
      expect(notified, isTrue);
    });

    test('notifies listeners on setSeasonalTypeFilter', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.setSeasonalTypeFilter('Movie');
      expect(notified, isTrue);
    });
  });

  // ── Genres ────────────────────────────────────────────────────
  group('fetchGenres', () {
    test('fetches genres successfully', () async {
      await provider.fetchGenres();
      expect(provider.genresState, FetchState.loaded);
      expect(provider.genres, isNotEmpty);
      expect(mockApi.getGenresCallCount, 1);
    });

    test('skips re-fetch when already loaded', () async {
      await provider.fetchGenres();
      await provider.fetchGenres();
      expect(mockApi.getGenresCallCount, 1);
    });
  });

  // ── Genre sort ────────────────────────────────────────────────
  group('sortedGenres / setGenreSort', () {
    setUp(() async {
      await provider.fetchGenres();
    });

    test('sortedGenres returns genres sorted by name by default', () {
      final sorted = provider.sortedGenres;
      expect(sorted, isNotEmpty);
    });

    test('setGenreSort count sorts by count descending', () {
      provider.setGenreSort('count');
      expect(provider.genreSort, 'count');
      expect(provider.sortedGenres, isNotEmpty);
    });

    test('setGenreSort name sorts alphabetically', () {
      provider.setGenreSort('name');
      expect(provider.genreSort, 'name');
    });

    test('setGenreSort notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.setGenreSort('count');
      expect(notified, isTrue);
    });
  });

  // ── Friendly error messages ───────────────────────────────────
  group('friendlyError messages', () {
    test('rate limit error message', () async {
      mockApi.shouldThrow = true;
      mockApi.throwMessage = '429 rate limit exceeded';
      await provider.fetchTopAnime();
      expect(provider.topAnimeErrorMessage, contains('Too many requests'));
    });

    test('network error message', () async {
      mockApi.shouldThrow = true;
      mockApi.throwMessage = 'SocketException: network unreachable';
      await provider.fetchTopAnime();
      expect(provider.topAnimeErrorMessage, contains('internet'));
    });

    test('timeout error message', () async {
      mockApi.shouldThrow = true;
      mockApi.throwMessage = 'timeout occurred';
      await provider.fetchTopAnime();
      expect(provider.topAnimeErrorMessage, contains('timed out'));
    });

    test('404 error message', () async {
      mockApi.shouldThrow = true;
      mockApi.throwMessage = '404 not found';
      await provider.fetchTopAnime();
      expect(provider.topAnimeErrorMessage, contains('not found'));
    });

    test('generic error message', () async {
      mockApi.shouldThrow = true;
      mockApi.throwMessage = 'something completely unexpected';
      await provider.fetchTopAnime();
      expect(provider.topAnimeErrorMessage, contains('went wrong'));
    });
  });
}