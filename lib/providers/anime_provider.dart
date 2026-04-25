import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../services/api_service.dart';

enum FetchState { initial, loading, loaded, error }

class AnimeProvider extends ChangeNotifier {
  final ApiService _apiService;

  AnimeProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // ── Top Anime ────────────────────────────────────────────────
  List<Anime> _topAnime = [];
  FetchState _topAnimeState = FetchState.initial;
  int _currentTopPage = 1;

  List<Anime> get topAnime => _topAnime;
  FetchState get topAnimeState => _topAnimeState;

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

  // ── Shared ───────────────────────────────────────────────────
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ── Top Anime ────────────────────────────────────────────────
  Future<void> fetchTopAnime({bool loadMore = false}) async {
    if (loadMore) {
      // Do not trigger another fetch while one is already in progress.
      if (_topAnimeState == FetchState.loading) return;
      _currentTopPage++;
    } else {
      _currentTopPage = 1;
      _topAnime = [];
      _topAnimeState = FetchState.loading;
      notifyListeners();
    }

    try {
      final results = await _apiService.getTopAnime(page: _currentTopPage);
      if (loadMore) {
        _topAnime = [..._topAnime, ...results];
      } else {
        _topAnime = results;
      }
      _topAnimeState = FetchState.loaded;
    } catch (e) {
      _topAnimeState = FetchState.error;
      _errorMessage = e.toString();
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

    // A new query always resets pagination regardless of loadMore flag.
    if (query != _currentQuery) {
      _currentQuery = query;
      loadMore = false;
    }

    if (loadMore) {
      // Do not trigger another fetch while one is already in progress.
      if (_searchState == FetchState.loading) return;
      _currentSearchPage++;
    } else {
      _currentSearchPage = 1;
      _searchResults = [];
      _searchState = FetchState.loading;
      notifyListeners();
    }

    try {
      final results = await _apiService.searchAnime(query, page: _currentSearchPage);
      if (loadMore) {
        _searchResults = [..._searchResults, ...results];
      } else {
        _searchResults = results;
      }
      _searchState = FetchState.loaded;
    } catch (e) {
      _searchState = FetchState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ── Recommendations ──────────────────────────────────────────

  /// Fetches recommendations for the given [malId].
  /// The Jikan recommendations endpoint does not support pagination,
  /// so [loadMore] is intentionally ignored — all results are returned at once.
  Future<void> fetchRecommendations(int malId) async {
    // Skip if we already have results for this anime or a fetch is in progress.
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

  // ── Detail ───────────────────────────────────────────────────
  Future<Anime> getAnimeDetails(int malId) async {
    return _apiService.getAnimeDetails(malId);
  }
}