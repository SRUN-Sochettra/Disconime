import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_model.dart';
import '../models/filter_model.dart';

// FavoritesActiveFilter is now defined in filter_model.dart
// and imported above — no local class definition needed here.

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorites';

  final Map<int, Anime> _favorites = {};
  FavoritesActiveFilter _activeFilter = const FavoritesActiveFilter();

  List<Anime>? _cachedList;
  SharedPreferences? _prefs;
  bool _pendingPersist = false;

  // ── Public getters ───────────────────────────────────────────
  List<Anime> get favorites => _cachedList ??= _favorites.values.toList();

  FavoritesActiveFilter get activeFilter => _activeFilter;

  bool isFavorite(int malId) => _favorites.containsKey(malId);

  List<Anime> get filteredFavorites {
    var list = _favorites.values.toList();

    if (_activeFilter.type != null && _activeFilter.type!.isNotEmpty) {
      list = list
          .where((a) =>
      a.type?.toLowerCase() == _activeFilter.type!.toLowerCase())
          .toList();
    }

    switch (_activeFilter.orderBy) {
      case 'title':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'score':
        list.sort((a, b) =>
            (b.score.value ?? 0.0).compareTo(a.score.value ?? 0.0));
        break;
      case 'date_added':
      default:
        list = list.reversed.toList();
        break;
    }

    return list;
  }

  // ── Filter management ────────────────────────────────────────
  void updateFilter({String? type, String? orderBy}) {
    _activeFilter = _activeFilter.copyWith(
      type: type != null ? () => type.isEmpty ? null : type : null,
      orderBy: orderBy,
    );
    notifyListeners();
  }

  void clearFilters() {
    _activeFilter = const FavoritesActiveFilter();
    notifyListeners();
  }

  // ── Persistence ──────────────────────────────────────────────
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
      _cachedList = null;
      notifyListeners();
    } catch (e) {
      debugPrint('[FavoritesProvider] failed to load favorites: $e');
    }
  }

  void toggleFavorite(Anime anime) {
    if (_favorites.containsKey(anime.malId)) {
      _favorites.remove(anime.malId);
    } else {
      _favorites[anime.malId] = anime;
    }
    _cachedList = null;
    notifyListeners();
    _schedulePersist();
  }

  Future<void>? _activePersist;

  void _schedulePersist() {
    if (_pendingPersist) return;
    _pendingPersist = true;

    Future.microtask(() async {
      _pendingPersist = false;
      final completer = Completer<void>();
      final previous = _activePersist;
      _activePersist = completer.future;
      try {
        if (previous != null) await previous;
        await _persist();
      } finally {
        completer.complete();
      }
    });
  }

  Future<void> _persist() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final List<String> encoded =
      _favorites.values.map((a) => json.encode(a.toJson())).toList();
      await prefs.setStringList(_storageKey, encoded);
    } catch (e) {
      debugPrint('[FavoritesProvider] failed to persist favorites: $e');
    }
  }
}