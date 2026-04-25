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

  List<Anime> get topAnime => _topAnime;
  FetchState get topAnimeState => _topAnimeState;
  AnimeFilter get currentFilter => _currentFilter;

  // ── Search ───────────────────────────────────────────────────
  List<Anime> _searchResults = [];
  FetchState _searchState = FetchState.initial;
  int _currentSearchPage = 1;
  String _currentQuery = '';

  List<Anime> get searchResults => _searchResults;
  FetchState get searchState => _searchState;

  // ── Recommendations ──────────────────────────────────────────
  List<Anime> _recommendations = [];
  FetchState _recommendationsState = FetchState.initial;
  int _currentRecMalId = 0;

  List<Anime> get recommendations => _recommendations;
  FetchState get recommendationsState => _recommendationsState;

  // ── Seasonal ─────────────────────────────────────────────────
  List<Anime> _seasonalAnime = [];
  FetchState _seasonalState = FetchState.initial;
  int _currentSeasonalPage = 1;
  int? _selectedYear;
  String? _selectedSeason;

  List<Anime> get seasonalAnime => _seasonalAnime;
  FetchState get seasonalState => _seasonalState;
  int? get selectedYear => _selectedYear;
  String? get selectedSeason => _selectedSeason;

  String get seasonLabel {
    if (_selectedYear == null || _selectedSeason == null) {
      return 'Current Season';
    }
    return '${_selectedSeason![0].toUpperCase()}${_selectedSeason!.substring(1)} $_selectedYear';
  }

  // ── Genres ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _genres = [];
  FetchState _genresState = FetchState.initial;

  List<Map<String, dynamic>> get genres => _genres;
  FetchState get genresState => _genresState;

  List<Anime> _genreAnime = [];
  FetchState _genreAnimeState = FetchState.initial;
  int _currentGenrePage = 1;
  int _currentGenreId = 0;
  String _currentGenreName = '';

  List<Anime> get genreAnime => _genreAnime;
  FetchState get genreAnimeState => _genreAnimeState;
  String get currentGenreName => _currentGenreName;

  // ── Shared ───────────────────────────────────────────────────
  String _errorMessage = '';
  String _topAnimeErrorMessage = '';
  String get errorMessage => _errorMessage;
  String get topAnimeErrorMessage => _topAnimeErrorMessage;

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
      _topAnimeErrorMessage = '';
      notifyListeners();
    } else {
      _topAnime = [];
      _topAnimeState = FetchState.loading;
      _topAnimeErrorMessage = '';
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
      _topAnimeErrorMessage = '';
    } catch (e) {
      _topAnimeState = FetchState.error;
      _topAnimeErrorMessage = e.toString();
      _errorMessage = _topAnimeErrorMessage;
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
    } catch (e) {
      _searchState = FetchState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ── Recommendations ──────────────────────────────────────────
  Future<void> fetchRecommendations(int malId) async {
    if (_currentRecMalId == malId &&
        (_recommendationsState == FetchState.loaded ||
            _recommendationsState == FetchState.loading)) {
      return;
    }
    _currentRecMalId = malId;
    _recommendations = [];
    _recommendationsState = FetchState.loading;
    notifyListeners();

    try {
      _recommendations = await _apiService.getAnimeRecommendations(malId);
      _recommendationsState = FetchState.loaded;
    } catch (e) {
      _recommendationsState = FetchState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
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
    } catch (e) {
      _seasonalState = FetchState.error;
      _errorMessage = e.toString();
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
    } catch (e) {
      _genresState = FetchState.error;
      _errorMessage = e.toString();
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
    } catch (e) {
      _genreAnimeState = FetchState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ── Detail ───────────────────────────────────────────────────
  Future<Anime> getAnimeDetails(int malId) async {
    return _apiService.getAnimeDetails(malId);
  }
}
