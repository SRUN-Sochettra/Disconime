import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_model.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorites';

  // Ordered map so insertion order is preserved (most recently added first).
  final Map<int, Anime> _favorites = {};

  List<Anime> get favorites => _favorites.values.toList();

  bool isFavorite(int malId) => _favorites.containsKey(malId);

  /// Loads favorites from shared_preferences on app start.
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? encoded = prefs.getStringList(_storageKey);

      if (encoded == null || encoded.isEmpty) return;

      for (final item in encoded) {
        try {
          final map = json.decode(item) as Map<String, dynamic>;
          final anime = Anime.fromLocalJson(map);
          _favorites[anime.malId] = anime;
        } catch (e) {
          debugPrint('[FavoritesProvider] failed to parse favorite: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[FavoritesProvider] failed to load favorites: $e');
    }
  }

  /// Adds or removes an anime from favorites and persists the change.
  Future<void> toggleFavorite(Anime anime) async {
    if (_favorites.containsKey(anime.malId)) {
      _favorites.remove(anime.malId);
    } else {
      _favorites[anime.malId] = anime;
    }
    notifyListeners();
    await _persist();
  }

  /// Writes the current favorites list to shared_preferences.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encoded = _favorites.values
          .map((anime) => json.encode(anime.toJson()))
          .toList();
      await prefs.setStringList(_storageKey, encoded);
    } catch (e) {
      debugPrint('[FavoritesProvider] failed to persist favorites: $e');
    }
  }
}