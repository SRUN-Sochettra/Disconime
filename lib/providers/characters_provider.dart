import 'package:flutter/foundation.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';
import '../utils/error_utils.dart';
import 'fetch_state.dart';

class CharactersProvider extends ChangeNotifier {
  final ApiService _apiService;

  CharactersProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<TopCharacter> _topCharacters = [];
  FetchState _topCharactersState = FetchState.initial;
  int _currentPage = 1;
  bool _hasMore = true;
  String _topCharactersError = '';
  String _characterSort = 'favorites'; // 'favorites', 'name', 'az'

  List<TopCharacter> get topCharacters => _topCharacters;
  FetchState get topCharactersState => _topCharactersState;
  String get characterSort => _characterSort;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String get topCharactersErrorMessage => _topCharactersError;

  List<TopCharacter> get sortedCharacters {
    if (_topCharacters.isEmpty) return [];
    var results = List<TopCharacter>.from(_topCharacters);

    if (_characterSort == 'name') {
      results.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    } else if (_characterSort == 'az') {
      results.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    } else if (_characterSort == 'favorites') {
      results.sort(
          (a, b) => (b.favorites ?? 0).compareTo(a.favorites ?? 0));
    }
    return results;
  }

  void setCharacterSort(String sort) {
    _characterSort = sort;
    notifyListeners();
  }

  final Map<int, Character> _detailCache = {};
  final Map<int, FetchState> _detailStates = {};
  final Map<int, String> _detailErrors = {};

  Character? detailFor(int malId) => _detailCache[malId];
  FetchState detailStateFor(int malId) =>
      _detailStates[malId] ?? FetchState.initial;
  String detailErrorFor(int malId) => _detailErrors[malId] ?? '';

  Future<void> fetchTopCharacters({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore) return;
      if (_topCharactersState == FetchState.loading) return;
    } else {
      if (_topCharactersState == FetchState.loading) return;
      _topCharacters = [];
      _currentPage = 1;
      _hasMore = true;
    }

    // FIX: Direct notify, no microtask
    _topCharactersState = FetchState.loading;
    _topCharactersError = '';
    notifyListeners();

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
      _topCharactersError = friendlyError(e);
    }
    notifyListeners();
  }

  Future<void> fetchCharacterDetail(int malId) async {
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
      _detailErrors[malId] = friendlyError(e);
    }
    notifyListeners();
  }
}