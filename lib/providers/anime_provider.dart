import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../models/filter_model.dart';
import '../services/api_service.dart';
import '../utils/error_utils.dart';
import 'fetch_state.dart';

class AnimeProvider extends ChangeNotifier {
  final ApiService _apiService;

  AnimeProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ── Top Anime ────────────────────────────────────────────────
  List<Anime> _topAnime = [];
  FetchState _topAnimeState = FetchState.initial;
  int _currentTopPage = 1;
  bool _hasMoreTopAnime = true;
  AnimeFilter _currentFilter = const AnimeFilter();
  String _topAnimeError = '';

  List<Anime> get topAnime => _topAnime;
  FetchState get topAnimeState => _topAnimeState;
  AnimeFilter get currentFilter => _currentFilter;
  String get topAnimeErrorMessage => _topAnimeError;
  int get currentTopPage => _currentTopPage;
  bool get hasMoreTopAnime => _hasMoreTopAnime;

  // ── Search ───────────────────────────────────────────────────
  List<Anime> _searchResults = [];
  FetchState _searchState = FetchState.initial;
  int _currentSearchPage = 1;
  bool _hasMoreSearchResults = true;
  String _currentQuery = '';
  AnimeFilter _searchFilter = const AnimeFilter();
  String _searchError = '';

  List<Anime> get searchResults => _searchResults;
  FetchState get searchState => _searchState;
  AnimeFilter get searchFilter => _searchFilter;
  String get searchErrorMessage => _searchError;
  int get currentSearchPage => _currentSearchPage;
  bool get hasMoreSearchResults => _hasMoreSearchResults;

  // ── Recommendations ──────────────────────────────────────────
  List<Anime> _recommendations = [];
  FetchState _recommendationsState = FetchState.initial;
  int _currentRecMalId = 0;
  String _recommendationsError = '';

  List<Anime> get recommendations => _recommendations;
  FetchState get recommendationsState => _recommendationsState;
  String get recommendationsErrorMessage => _recommendationsError;
  int get currentRecMalId => _currentRecMalId;

  // ── Characters ───────────────────────────────────────────────
  List<AnimeCharacter> _characters = [];
  FetchState _charactersState = FetchState.initial;
  int _currentCharactersMalId = 0;
  String _charactersError = '';

  List<AnimeCharacter> get characters => _characters;
  FetchState get charactersState => _charactersState;
  String get charactersErrorMessage => _charactersError;

  // ── Staff ────────────────────────────────────────────────────
  List<AnimeStaff> _staff = [];
  FetchState _staffState = FetchState.initial;
  int _currentStaffMalId = 0;
  String _staffError = '';

  List<AnimeStaff> get staff => _staff;
  FetchState get staffState => _staffState;
  String get staffErrorMessage => _staffError;

  // ── Seasonal ─────────────────────────────────────────────────
  List<Anime> _seasonalAnime = [];
  FetchState _seasonalState = FetchState.initial;
  int _currentSeasonalPage = 1;
  bool _hasMoreSeasonalAnime = true;
  int? _selectedYear;
  String? _selectedSeason;
  String _seasonalError = '';

  // Client-side seasonal filter state
  String _seasonalSort = 'score'; // 'score' or 'title'
  String? _seasonalTypeFilter;   // null = all

  List<Anime> get seasonalAnime => _seasonalAnime;
  FetchState get seasonalState => _seasonalState;
  int? get selectedYear => _selectedYear;
  String? get selectedSeason => _selectedSeason;
  String get seasonalErrorMessage => _seasonalError;
  int get currentSeasonalPage => _currentSeasonalPage;
  bool get hasMoreSeasonalAnime => _hasMoreSeasonalAnime;
  String get seasonalSort => _seasonalSort;
  String? get seasonalTypeFilter => _seasonalTypeFilter;

  List<Anime> get filteredSeasonalAnime {
    if (_seasonalAnime.isEmpty) return [];

    var results = List<Anime>.from(_seasonalAnime);

    // Apply type filter
    if (_seasonalTypeFilter != null) {
      results = results
          .where((a) =>
      a.type?.toLowerCase() == _seasonalTypeFilter!.toLowerCase())
          .toList();
    }

    // Apply sorting
    if (_seasonalSort == 'title') {
      results.sort((a, b) => a.title.compareTo(b.title));
    } else {
      // Default: sort by score descending
      results.sort(
              (a, b) => (b.score.value ?? 0.0).compareTo(a.score.value ?? 0.0));
    }

    return results;
  }

  void setSeasonalSort(String sort) {
    _seasonalSort = sort;
    notifyListeners();
  }

  void setSeasonalTypeFilter(String? type) {
    _seasonalTypeFilter = type;
    notifyListeners();
  }

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
  String _genreSort = 'name'; // 'name' or 'count'
  String _genresError = '';

  List<Map<String, dynamic>> get genres => _genres;
  FetchState get genresState => _genresState;
  String get genreSort => _genreSort;
  String get genresErrorMessage => _genresError;

  // Single definition of sortedGenres
  List<Map<String, dynamic>> get sortedGenres {
    if (_genres.isEmpty) return [];
    final list = List<Map<String, dynamic>>.from(_genres);
    if (_genreSort == 'name') {
      list.sort(
              (a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } else if (_genreSort == 'count') {
      list.sort((a, b) =>
          ((b['count'] as int?) ?? 0).compareTo((a['count'] as int?) ?? 0));
    }
    return list;
  }

  void setGenreSort(String sort) {
    _genreSort = sort;
    notifyListeners();
  }

  // ── Genre Detail ─────────────────────────────────────────────
  List<Anime> _genreAnime = [];
  FetchState _genreAnimeState = FetchState.initial;
  int _currentGenrePage = 1;
  bool _hasMoreGenreAnime = true;
  int _currentGenreId = 0;
  String _currentGenreName = '';
  String _genreAnimeError = '';

  List<Anime> get genreAnime => _genreAnime;
  FetchState get genreAnimeState => _genreAnimeState;
  String get currentGenreName => _currentGenreName;
  String get genreAnimeErrorMessage => _genreAnimeError;
  int get currentGenrePage => _currentGenrePage;
  bool get hasMoreGenreAnime => _hasMoreGenreAnime;

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
      if (!_hasMoreTopAnime) return;
      if (_topAnimeState == FetchState.loading) return;
    } else {
      if (_topAnimeState == FetchState.loading) return;
      _topAnime = [];
      _currentTopPage = 1;
      _hasMoreTopAnime = true;
    }

    _topAnimeState = FetchState.loading;
    _topAnimeError = '';
    notifyListeners();

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
      if (results.isEmpty) _hasMoreTopAnime = false;
      _topAnime = loadMore ? [..._topAnime, ...results] : results;
      _currentTopPage = pageToFetch;
      _topAnimeState = FetchState.loaded;
      _topAnimeError = '';
    } catch (e) {
      _topAnimeState = FetchState.error;
      _topAnimeError = friendlyError(e);
    }
    notifyListeners();
  }

  // ── Search ───────────────────────────────────────────────────
  void applySearchFilter(AnimeFilter filter) {
    _searchFilter = filter;
    if (_currentQuery.isNotEmpty) {
      searchAnime(_currentQuery);
    }
  }

  void clearSearchFilter() {
    _searchFilter = const AnimeFilter();
    if (_currentQuery.isNotEmpty) {
      searchAnime(_currentQuery);
    }
  }

  Future<void> searchAnime(
      String query, {
        bool loadMore = false,
        String? status,
      }) async {
    if (query.isEmpty) {
      _searchState = FetchState.initial;
      _searchResults = [];
      _currentQuery = '';
      _hasMoreSearchResults = true;
      notifyListeners();
      return;
    }

    // If a direct status arg is passed (from the quick filter chips),
    // update the search filter's 'filter' field to match.
    if (status != null) {
      _searchFilter = _searchFilter.copyWith(
        filter: () => (status.isEmpty) ? null : status,
      );
    }

    if (query != _currentQuery) {
      _currentQuery = query;
      _hasMoreSearchResults = true;
      loadMore = false;
    }

    if (loadMore) {
      if (!_hasMoreSearchResults) return;
      if (_searchState == FetchState.loading) return;
    } else {
      if (_searchState == FetchState.loading) return;
      _searchResults = [];
    }

    _searchState = FetchState.loading;
    notifyListeners();

    final pageToFetch = loadMore ? _currentSearchPage + 1 : 1;

    try {
      final results = await _apiService.searchAnime(
        query,
        page: pageToFetch,
        type: _searchFilter.type,
        status: _searchFilter.filter,
        rating: _searchFilter.rating,
        orderBy: _searchFilter.orderBy,
        sort: _searchFilter.sort,
      );
      if (query != _currentQuery) return;
      if (results.isEmpty) _hasMoreSearchResults = false;
      _searchResults =
      loadMore ? [..._searchResults, ...results] : results;
      _currentSearchPage = pageToFetch;
      _searchState = FetchState.loaded;
      _searchError = '';
    } catch (e) {
      if (query != _currentQuery) return;
      _searchState = FetchState.error;
      _searchError = friendlyError(e);
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
    _recommendationsError = '';
    notifyListeners();

    try {
      final results = await _apiService.getAnimeRecommendations(malId);
      if (malId != _currentRecMalId) return;
      _recommendations = results;
      _recommendationsState = FetchState.loaded;
    } catch (e) {
      if (malId != _currentRecMalId) return;
      _recommendationsState = FetchState.error;
      _recommendationsError = friendlyError(e);
    }
    notifyListeners();
  }

  void clearRecommendations() {
    _currentRecMalId = 0;
    _recommendations = [];
    _recommendationsState = FetchState.initial;
    _recommendationsError = '';
  }

  // ── Characters ───────────────────────────────────────────────
  Future<void> fetchCharacters(int malId) async {
    if (_currentCharactersMalId == malId &&
        (_charactersState == FetchState.loaded ||
            _charactersState == FetchState.loading)) {
      return;
    }

    _currentCharactersMalId = malId;
    _characters = [];
    _charactersState = FetchState.loading;
    _charactersError = '';
    notifyListeners();

    try {
      final results = await _apiService.getAnimeCharacters(malId);
      if (malId != _currentCharactersMalId) return;
      _characters = results;
      _charactersState = FetchState.loaded;
    } catch (e) {
      if (malId != _currentCharactersMalId) return;
      _charactersState = FetchState.error;
      _charactersError = friendlyError(e);
    }
    notifyListeners();
  }

  void clearCharacters() {
    _currentCharactersMalId = 0;
    _characters = [];
    _charactersState = FetchState.initial;
    _charactersError = '';
  }

  // ── Staff ────────────────────────────────────────────────────
  Future<void> fetchStaff(int malId) async {
    if (_currentStaffMalId == malId &&
        (_staffState == FetchState.loaded ||
            _staffState == FetchState.loading)) {
      return;
    }

    _currentStaffMalId = malId;
    _staff = [];
    _staffState = FetchState.loading;
    _staffError = '';
    notifyListeners();

    try {
      final results = await _apiService.getAnimeStaff(malId);
      if (malId != _currentStaffMalId) return;
      _staff = results;
      _staffState = FetchState.loaded;
    } catch (e) {
      if (malId != _currentStaffMalId) return;
      _staffState = FetchState.error;
      _staffError = friendlyError(e);
    }
    notifyListeners();
  }

  void clearStaff() {
    _currentStaffMalId = 0;
    _staff = [];
    _staffState = FetchState.initial;
    _staffError = '';
  }

  void clearDetailData() {
    clearRecommendations();
    clearCharacters();
    clearStaff();
  }

  // ── Seasonal ─────────────────────────────────────────────────
  Future<void> fetchSeasonalAnime({
    int? year,
    String? season,
    bool loadMore = false,
  }) async {
    final isNewSelection =
        year != _selectedYear || season != _selectedSeason;
    if (isNewSelection) {
      _selectedYear = year;
      _selectedSeason = season;
      _hasMoreSeasonalAnime = true;
      loadMore = false;
    }

    if (loadMore) {
      if (!_hasMoreSeasonalAnime) return;
      if (_seasonalState == FetchState.loading) return;
    } else {
      if (_seasonalState == FetchState.loading) return;
      _seasonalAnime = [];
      _currentSeasonalPage = 1;
      _hasMoreSeasonalAnime = true;
    }

    _seasonalState = FetchState.loading;
    notifyListeners();

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
      if (results.isEmpty) _hasMoreSeasonalAnime = false;
      _seasonalAnime =
      loadMore ? [..._seasonalAnime, ...results] : results;
      _currentSeasonalPage = pageToFetch;
      _seasonalState = FetchState.loaded;
      _seasonalError = '';
    } catch (e) {
      _seasonalState = FetchState.error;
      _seasonalError = friendlyError(e);
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
      _genresError = friendlyError(e);
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
      _hasMoreGenreAnime = true;
      loadMore = false;
    }

    if (loadMore) {
      if (!_hasMoreGenreAnime) return;
      if (_genreAnimeState == FetchState.loading) return;
    } else {
      if (_genreAnimeState == FetchState.loading) return;
      _genreAnime = [];
      _currentGenrePage = 1;
      _hasMoreGenreAnime = true;
    }

    _genreAnimeState = FetchState.loading;
    notifyListeners();

    final pageToFetch = loadMore ? _currentGenrePage + 1 : 1;

    try {
      final results = await _apiService.getAnimeByGenre(
        genreId,
        page: pageToFetch,
      );
      if (genreId != _currentGenreId) return;
      if (results.isEmpty) _hasMoreGenreAnime = false;
      _genreAnime = loadMore ? [..._genreAnime, ...results] : results;
      _currentGenrePage = pageToFetch;
      _genreAnimeState = FetchState.loaded;
      _genreAnimeError = '';
    } catch (e) {
      _genreAnimeState = FetchState.error;
      _genreAnimeError = friendlyError(e);
    }
    notifyListeners();
  }

  // ── Detail ───────────────────────────────────────────────────
  Future<Anime> getAnimeDetails(int malId) async {
    return _apiService.getAnimeDetails(malId);
  }
}