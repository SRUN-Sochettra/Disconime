import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../services/api_service.dart';

enum FetchState { initial, loading, loaded, error }

class AnimeProvider extends ChangeNotifier {
  final ApiService _apiService;

  AnimeProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Anime> _topAnime = [];
  List<Anime> _searchResults = [];
  
  FetchState _topAnimeState = FetchState.initial;
  FetchState _searchState = FetchState.initial;
  
  String _errorMessage = '';
  int _currentTopPage = 1;
  int _currentSearchPage = 1;
  String _currentQuery = '';

  List<Anime> get topAnime => _topAnime;
  List<Anime> get searchResults => _searchResults;
  FetchState get topAnimeState => _topAnimeState;
  FetchState get searchState => _searchState;
  String get errorMessage => _errorMessage;

  Future<void> fetchTopAnime({bool loadMore = false}) async {
    if (loadMore) {
      _currentTopPage++;
    } else {
      _currentTopPage = 1;
      _topAnimeState = FetchState.loading;
      _topAnime = [];
      notifyListeners();
    }

    try {
      final results = await _apiService.getTopAnime(page: _currentTopPage);
      if (loadMore) {
        _topAnime.addAll(results);
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

  Future<void> searchAnime(String query, {bool loadMore = false}) async {
    if (query.isEmpty) {
      _searchState = FetchState.initial;
      _searchResults = [];
      notifyListeners();
      return;
    }

    if (query != _currentQuery) {
      _currentQuery = query;
      loadMore = false;
    }

    if (loadMore) {
      _currentSearchPage++;
    } else {
      _currentSearchPage = 1;
      _searchState = FetchState.loading;
      _searchResults = [];
      notifyListeners();
    }

    try {
      final results = await _apiService.searchAnime(query, page: _currentSearchPage);
      if (loadMore) {
        _searchResults.addAll(results);
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

  List<Anime> _recommendations = [];
  FetchState _recommendationsState = FetchState.initial;
  int _currentRecommendationsPage = 1;
  int _currentRecMalId = 0;

  List<Anime> get recommendations => _recommendations;
  FetchState get recommendationsState => _recommendationsState;

  Future<void> fetchRecommendations(int malId, {bool loadMore = false}) async {
    if (_currentRecMalId != malId) {
      _currentRecMalId = malId;
      loadMore = false;
    }

    if (loadMore) {
      _currentRecommendationsPage++;
    } else {
      _currentRecommendationsPage = 1;
      _recommendationsState = FetchState.loading;
      _recommendations = [];
      notifyListeners();
    }

    try {
      final newRecs = await _apiService.getAnimeRecommendations(malId, page: _currentRecommendationsPage);
      if (loadMore) {
        _recommendations.addAll(newRecs);
      } else {
        _recommendations = newRecs;
      }
      _recommendationsState = FetchState.loaded;
    } catch (e) {
      _recommendationsState = FetchState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<Anime> getAnimeDetails(int malId) async {
    return await _apiService.getAnimeDetails(malId);
  }
}
