import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_model.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorites';

  final Map<int, Anime> _favorites = {};

  // FIX: Cache the list so we don't allocate a new List<Anime>
  // on every call to the getter. Invalidated on every mutation.
  List<Anime>? _cachedList;

  // FIX: Guard flag prevents concurrent toggleFavorite calls
  // (e.g. rapid taps) from interleaving map mutation and persist.
  bool _isPersisting = false;

  // FIX: Cache the SharedPreferences instance after first load
  // so every _persist() call does not pay the getInstance() cost.
  SharedPreferences? _prefs;

  List<Anime> get favorites => _cachedList ??= _favorites.values.toList();

  bool isFavorite(int malId) => _favorites.containsKey(malId);

  Future<void> loadFavorites() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final List<String>? encoded = _prefs!.getStringList(_storageKey);
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
      // Invalidate cache after bulk load.
      _cachedList = null;
      notifyListeners();
    } catch (e) {
      debugPrint('[FavoritesProvider] failed to load favorites: $e');
    }
  }

  Future<void> toggleFavorite(Anime anime) async {
    // FIX: Ignore rapid taps while a persist is in flight.
    if (_isPersisting) return;
    _isPersisting = true;

    if (_favorites.containsKey(anime.malId)) {
      _favorites.remove(anime.malId);
    } else {
      _favorites[anime.malId] = anime;
    }

    // Invalidate cache on every mutation.
    _cachedList = null;
    notifyListeners();
    await _persist();

    _isPersisting = false;
  }

  Future<void> _persist() async {
    try {
      // FIX: Use cached prefs instance — falls back to getInstance()
      // only if loadFavorites() was somehow never called.
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final List<String> encoded =
          _favorites.values.map((a) => json.encode(a.toJson())).toList();
      await prefs.setStringList(_storageKey, encoded);
    } catch (e) {
      debugPrint('[FavoritesProvider] failed to persist favorites: $e');
    }
  }
}