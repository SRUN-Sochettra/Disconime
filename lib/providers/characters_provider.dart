import 'package:flutter/foundation.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';

enum FetchState { initial, loading, loaded, error }

class CharactersProvider extends ChangeNotifier {
  final ApiService _apiService;

  CharactersProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ── Top Characters list ───────────────────────────────────────
  List<TopCharacter> _topCharacters = [];
  FetchState _topCharactersState = FetchState.initial;
  int _currentPage = 1;
  bool _hasMore = true;
  String _topCharactersError = '';

  List<TopCharacter> get topCharacters => _topCharacters;
  FetchState get topCharactersState => _topCharactersState;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String get topCharactersErrorMessage => _topCharactersError;

  // ── Character Detail ──────────────────────────────────────────
  // Cached per malId so navigating back and re-tapping is instant.
  final Map<int, Character> _detailCache = {};
  final Map<int, FetchState> _detailStates = {};
  final Map<int, String> _detailErrors = {};

  Character? detailFor(int malId) => _detailCache[malId];
  FetchState detailStateFor(int malId) =>
      _detailStates[malId] ?? FetchState.initial;
  String detailErrorFor(int malId) => _detailErrors[malId] ?? '';

  // ── Fetch top characters ──────────────────────────────────────
  Future<void> fetchTopCharacters({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore) return;
      if (_topCharactersState == FetchState.loading) return;
      _topCharactersState = FetchState.loading;
      _topCharactersError = '';
      notifyListeners();
    } else {
      _topCharacters = [];
      _currentPage = 1;
      _hasMore = true;
      _topCharactersState = FetchState.loading;
      _topCharactersError = '';
      notifyListeners();
    }

    final pageToFetch = loadMore ? _currentPage + 1 : 1;

    try {
      final results = await _apiService.getTopCharacters(
        page: pageToFetch,
      );
      if (results.isEmpty) _hasMore = false;
      _topCharacters = loadMore
          ? [..._topCharacters, ...results]
          : results;
      _currentPage = pageToFetch;
      _topCharactersState = FetchState.loaded;
      _topCharactersError = '';
    } catch (e) {
      _topCharactersState = FetchState.error;
      _topCharactersError = _friendlyError(e);
    }
    notifyListeners();
  }

  // ── Fetch character detail ────────────────────────────────────
  Future<void> fetchCharacterDetail(int malId) async {
    // Return cached result immediately.
    if (_detailStates[malId] == FetchState.loaded) return;
    if (_detailStates[malId] == FetchState.loading) return;

    _detailStates[malId] = FetchState.loading;
    _detailErrors[malId] = '';
    notifyListeners();

    try {
      final character = await _apiService.getCharacterDetail(malId);
      _detailCache[malId] = character;
      _detailStates[malId] = FetchState.loaded;
    } catch (e) {
      _detailStates[malId] = FetchState.error;
      _detailErrors[malId] = _friendlyError(e);
    }
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────
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
    return 'Something went wrong. Please try again.';
  }
}