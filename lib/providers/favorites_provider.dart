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

  // Cache the SharedPreferences instance after first load
  // so every _persist() call does not pay the getInstance() cost.
  SharedPreferences? _prefs;

  // Coalesces rapid toggles — only the last state is flushed to disk.
  bool _pendingPersist = false;

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

  void toggleFavorite(Anime anime) {
    // Always mutate in-memory state synchronously so no tap is ever dropped.
    if (_favorites.containsKey(anime.malId)) {
      _favorites.remove(anime.malId);
    } else {
      _favorites[anime.malId] = anime;
    }

    _cachedList = null;
    notifyListeners();
    _schedulePersist();
  }

  // Chained tracker to ensure sequential execution.
  Future<void>? _activePersist;

  void _schedulePersist() {
    if (_pendingPersist) return; // already scheduled
    _pendingPersist = true;

    Future.microtask(() async {
      _pendingPersist = false;

      // Track the current chain and append to it.
      final completer = Completer<void>();
      final previous = _activePersist;
      _activePersist = completer.future;

      try {
        // Wait for the previous write to finish before starting this one.
        if (previous != null) await previous;
        await _persist();
      } finally {
        completer.complete();
      }
    });
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