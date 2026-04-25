import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../models/filter_model.dart';
import '../services/api_service.dart';

enum FetchState { initial, loading, loaded, error }

class AnimeProvider extends ChangeNotifier {
  final ApiService _apiService;

  AnimeProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ── Top Anime ────────────────────────────────────────────────
  List<Anime> _topAnime = [];
  FetchState _topAnimeState = FetchState.initial;
  int _currentTopPage = 1;
  AnimeFilter _currentFilter = const AnimeFilter();

  // FIX: Dedicated error message per feature so concurrent
  // failures do not overwrite each other.
  String _topAnimeError = '';

  List<Anime> get topAnime => _topAnime;
  FetchState get topAnimeState => _topAnimeState;
  AnimeFilter get currentFilter => _currentFilter;
  String get topAnimeErrorMessage => _topAnimeError;

  // ── Search ───────────────────────────────────────────────────
  List<Anime> _searchResults = [];
  FetchState _searchState = FetchState.initial;
  int _currentSearchPage = 1;
  String _currentQuery = '';

  // FIX: Dedicated error message for search.
  String _searchError = '';

  List<Anime> get searchResults => _searchResults;
  FetchState get searchState => _searchState;
  String get searchErrorMessage => _searchError;

  // ── Recommendations ──────────────────────────────────────────
  List<Anime> _recommendations = [];
  FetchState _recommendationsState = FetchState.initial;
  int _currentRecMalId = 0;

  // FIX: Dedicated error message for recommendations.
  String _recommendationsError = '';

  List<Anime> get recommendations => _recommendations;
  FetchState get recommendationsState => _recommendationsState;
  String get recommendationsErrorMessage => _recommendationsError;

  // ── Seasonal ─────────────────────────────────────────────────
  List<Anime> _seasonalAnime = [];
  FetchState _seasonalState = FetchState.initial;
  int _currentSeasonalPage = 1;
  int? _selectedYear;
  String? _selectedSeason;

  // FIX: Dedicated error message for seasonal.
  String _seasonalError = '';

  List<Anime> get seasonalAnime => _seasonalAnime;
  FetchState get seasonalState => _seasonalState;
  int? get selectedYear => _selectedYear;
  String? get selectedSeason => _selectedSeason;
  String get seasonalErrorMessage => _seasonalError;

  String get seasonLabel {
    if (_selectedYear == null || _selectedSeason == null) {
      return 'Current Season';
    }
    return '${_selectedSeason![0].toUpperCase()}'
        '${_selectedSeason!.substring(1)} $_selectedYear';
  }

  // ── Genres ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _genres = [];
  FetchState _genresState = FetchState.initial;

  // FIX: Dedicated error message for genres.
  String _genresError = '';

  List<Map<String, dynamic>> get genres => _genres;
  FetchState get genresState => _genresState;
  String get genresErrorMessage => _genresError;

  // ── Genre Detail ─────────────────────────────────────────────
  List<Anime> _genreAnime = [];
  FetchState _genreAnimeState = FetchState.initial;
  int _currentGenrePage = 1;
  int _currentGenreId = 0;
  String _currentGenreName = '';

  // FIX: Dedicated error message for genre detail.
  String _genreAnimeError = '';

  List<Anime> get genreAnime => _genreAnime;
  FetchState get genreAnimeState => _genreAnimeState;
  String get currentGenreName => _currentGenreName;
  String get genreAnimeErrorMessage => _genreAnimeError;

  // ── Top Anime ────────────────────────────────────────────────
  void applyFilter(AnimeFilter filter) {
    _currentFilter = filter;
    fetchTopAnime();
  }

  void clearFilter() {
    _currentFilter = const AnimeFilter();
    fetchTopAnime();
  }

  Future<void> fetchTopAnime({bool loadMore = false}) async {
    if (loadMore) {
      if (_topAnimeState == FetchState.loading) return;
      _topAnimeState = FetchState.loading;
      _topAnimeError = '';
      notifyListeners();
    } else {
      _topAnime = [];
      _currentTopPage = 1;
      _topAnimeState = FetchState.loading;
      _topAnimeError = '';
      notifyListeners();
    }

    final pageToFetch = loadMore ? _currentTopPage + 1 : 1;

    try {
      final results = await _apiService.getTopAnime(
        page: pageToFetch,
        type: _currentFilter.type,
        filter: _currentFilter.filter,
        rating: _currentFilter.rating,
        orderBy: _currentFilter.orderBy,
        sort: _currentFilter.sort,
      );
      _topAnime = loadMore ? [..._topAnime, ...results] : results;
      _currentTopPage = pageToFetch;
      _topAnimeState = FetchState.loaded;
      _topAnimeError = '';
    } catch (e) {
      _topAnimeState = FetchState.error;
      _topAnimeError = _friendlyError(e);
    }
    notifyListeners();
  }

  // ── Search ───────────────────────────────────────────────────
  Future<void> searchAnime(String query, {bool loadMore = false}) async {
    if (query.isEmpty) {
      _searchState = FetchState.initial;
      _searchResults = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    if (query != _currentQuery) {
      _currentQuery = query;
      loadMore = false;
    }

    if (loadMore) {
      if (_searchState == FetchState.loading) return;
      _searchState = FetchState.loading;
      notifyListeners();
    } else {
      _searchResults = [];
      _searchState = FetchState.loading;
      notifyListeners();
    }

    final pageToFetch = loadMore ? _currentSearchPage + 1 : 1;

    try {
      final results = await _apiService.searchAnime(query, page: pageToFetch);
      _searchResults = loadMore ? [..._searchResults, ...results] : results;
      _currentSearchPage = pageToFetch;
      _searchState = FetchState.loaded;
      _searchError = '';
    } catch (e) {
      _searchState = FetchState.error;
      _searchError = _friendlyError(e);
    }
    notifyListeners();
  }

  // ── Recommendations ──────────────────────────────────────────
  // FIX: Removed the early-return guard that caused stale
  // recommendations when navigating A → B → back → A → B.
  // We now always re-fetch when the malId changes, and only
  // skip if the SAME anime is already loading or loaded.
  Future<void> fetchRecommendations(int malId) async {
    if (_currentRecMalId == malId &&
        (_recommendationsState == FetchState.loaded ||
            _recommendationsState == FetchState.loading)) {
      return;
    }

    _currentRecMalId = malId;
    _recommendations = [];
    _recommendationsState = FetchState.loading;
    _recommendationsError = '';
    notifyListeners();

    try {
      _recommendations = await _apiService.getAnimeRecommendations(malId);
      _recommendationsState = FetchState.loaded;
    } catch (e) {
      _recommendationsState = FetchState.error;
      _recommendationsError = _friendlyError(e);
    }
    notifyListeners();
  }

  /// Clears the cached recommendation malId so that navigating
  /// back to a previously visited DetailScreen always re-fetches.
  void clearRecommendations() {
    _currentRecMalId = 0;
    _recommendations = [];
    _recommendationsState = FetchState.initial;
    _recommendationsError = '';
  }

  // ── Seasonal ─────────────────────────────────────────────────
  Future<void> fetchSeasonalAnime({
    int? year,
    String? season,
    bool loadMore = false,
  }) async {
    final isNewSelection = year != _selectedYear || season != _selectedSeason;
    if (isNewSelection) {
      _selectedYear = year;
      _selectedSeason = season;
      loadMore = false;
    }

    if (loadMore) {
      if (_seasonalState == FetchState.loading) return;
      _seasonalState = FetchState.loading;
      notifyListeners();
    } else {
      _seasonalAnime = [];
      _currentSeasonalPage = 1;
      _seasonalState = FetchState.loading;
      notifyListeners();
    }

    final pageToFetch = loadMore ? _currentSeasonalPage + 1 : 1;

    try {
      List<Anime> results;
      if (_selectedYear != null && _selectedSeason != null) {
        results = await _apiService.getSeason(
          _selectedYear!,
          _selectedSeason!,
          page: pageToFetch,
        );
      } else {
        results = await _apiService.getSeasonNow(page: pageToFetch);
      }
      _seasonalAnime = loadMore ? [..._seasonalAnime, ...results] : results;
      _currentSeasonalPage = pageToFetch;
      _seasonalState = FetchState.loaded;
      _seasonalError = '';
    } catch (e) {
      _seasonalState = FetchState.error;
      _seasonalError = _friendlyError(e);
    }
    notifyListeners();
  }

  // ── Genres ───────────────────────────────────────────────────
  Future<void> fetchGenres() async {
    if (_genresState == FetchState.loaded ||
        _genresState == FetchState.loading) {
      return;
    }

    _genresState = FetchState.loading;
    notifyListeners();

    try {
      _genres = await _apiService.getGenres();
      _genresState = FetchState.loaded;
      _genresError = '';
    } catch (e) {
      _genresState = FetchState.error;
      _genresError = _friendlyError(e);
    }
    notifyListeners();
  }

  Future<void> fetchAnimeByGenre(
    int genreId,
    String genreName, {
    bool loadMore = false,
  }) async {
    if (_currentGenreId != genreId) {
      _currentGenreId = genreId;
      _currentGenreName = genreName;
      loadMore = false;
    }

    if (loadMore) {
      if (_genreAnimeState == FetchState.loading) return;
      _genreAnimeState = FetchState.loading;
      notifyListeners();
    } else {
      _genreAnime = [];
      _currentGenrePage = 1;
      _genreAnimeState = FetchState.loading;
      notifyListeners();
    }

    final pageToFetch = loadMore ? _currentGenrePage + 1 : 1;

    try {
      final results = await _apiService.getAnimeByGenre(
        genreId,
        page: pageToFetch,
      );
      _genreAnime = loadMore ? [..._genreAnime, ...results] : results;
      _currentGenrePage = pageToFetch;
      _genreAnimeState = FetchState.loaded;
      _genreAnimeError = '';
    } catch (e) {
      _genreAnimeState = FetchState.error;
      _genreAnimeError = _friendlyError(e);
    }
    notifyListeners();
  }

  // ── Detail ───────────────────────────────────────────────────
  Future<Anime> getAnimeDetails(int malId) async {
    return _apiService.getAnimeDetails(malId);
  }

  // ── Helpers ──────────────────────────────────────────────────
  // FIX: Converts raw exception messages into user-friendly strings
  // so ErrorView never shows a raw stack trace or status code.
  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('429') || msg.contains('rate limit')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    if (msg.contains('socketexception') || msg.contains('network')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('timeout')) {
      return 'The request timed out. Please try again.';
    }
    if (msg.contains('404')) {
      return 'Content not found.';
    }
    return 'Something went wrong. Please try again.';
  }
}