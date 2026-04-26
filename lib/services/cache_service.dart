import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/global_error_handler.dart';

class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  static const String _dataPrefix = 'cache_data_';
  static const String _timePrefix = 'cache_time_';

  static const Duration topAnimeTtl = Duration(minutes: 30);
  static const Duration searchTtl = Duration(minutes: 10);
  static const Duration detailTtl = Duration(hours: 6);
  static const Duration charactersTtl = Duration(hours: 6);
  static const Duration staffTtl = Duration(hours: 6);
  static const Duration seasonalTtl = Duration(minutes: 30);
  static const Duration genresTtl = Duration(hours: 24);
  static const Duration genreAnimeTtl = Duration(minutes: 30);
  static const Duration scheduleTtl = Duration(hours: 1);
  static const Duration recommendationsTtl = Duration(hours: 6);
  static const Duration topCharactersTtl = Duration(hours: 1);
  static const Duration characterDetailTtl = Duration(hours: 6);

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static const int _maxEntries = 100;

  // ── Write ─────────────────────────────────────────────────────
  Future<void> set(String key, dynamic data) async {
    try {
      final prefs = await _getPrefs();
      final encoded = json.encode(data);
      await prefs.setString('$_dataPrefix$key', encoded);
      await prefs.setInt(
        '$_timePrefix$key',
        DateTime.now().millisecondsSinceEpoch,
      );

      // FIX: Evict old entries to keep storage usage bounded (Issue #13)
      await _trimOldEntries(prefs);
    } catch (e, stack) {
      debugPrint('[CacheService] Failed to write $key: $e');
      GlobalErrorHandler.reportError(e, stack);
    }
  }

  /// Removes oldest entries if we exceed [_maxEntries].
  Future<void> _trimOldEntries(SharedPreferences prefs) async {
    final allKeys = prefs.getKeys();
    final timeKeys = allKeys.where((k) => k.startsWith(_timePrefix)).toList();

    if (timeKeys.length <= _maxEntries) return;

    // Collect all timestamps to find the oldest
    final entries = <MapEntry<String, int>>[];
    for (final tk in timeKeys) {
      final t = prefs.getInt(tk);
      if (t != null) {
        entries.add(MapEntry(tk, t));
      }
    }

    // Sort by timestamp (ascending - oldest first)
    entries.sort((a, b) => a.value.compareTo(b.value));

    // Remove the oldest 20% or whatever is needed to get back to 90% capacity
    // to avoid trimming on every single write once we hit the limit.
    final targetCount = (_maxEntries * 0.9).toInt();
    final numToRemove = timeKeys.length - targetCount;

    for (var i = 0; i < numToRemove; i++) {
      final timeKey = entries[i].key;
      final dataKey = timeKey.replaceFirst(_timePrefix, _dataPrefix);
      await prefs.remove(timeKey);
      await prefs.remove(dataKey);
    }

    debugPrint(
      '[CacheService] Evicted $numToRemove entries. New count: $targetCount',
    );
  }

  // ── Read ──────────────────────────────────────────────────────
  Future<dynamic> get(String key, {required Duration ttl}) async {
    try {
      final prefs = await _getPrefs();
      final timestamp = prefs.getInt('$_timePrefix$key');
      if (timestamp == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age >= ttl.inMilliseconds) return null;

      final encoded = prefs.getString('$_dataPrefix$key');
      if (encoded == null) return null;

      return json.decode(encoded);
    } catch (e, stack) {
      debugPrint('[CacheService] Failed to read $key: $e');
      GlobalErrorHandler.reportError(e, stack);
      return null;
    }
  }

  // ── Invalidate ────────────────────────────────────────────────
  Future<void> invalidate(String key) async {
    try {
      final prefs = await _getPrefs();
      await _delete(prefs, key);
    } catch (e, stack) {
      debugPrint('[CacheService] Failed to invalidate $key: $e');
      GlobalErrorHandler.reportError(e, stack);
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_dataPrefix) ||
            key.startsWith(_timePrefix)) {
          await prefs.remove(key);
        }
      }
      debugPrint('[CacheService] All cache cleared.');
    } catch (e, stack) {
      debugPrint('[CacheService] Failed to clear cache: $e');
      GlobalErrorHandler.reportError(e, stack);
    }
  }

  Future<void> _delete(SharedPreferences prefs, String key) async {
    await prefs.remove('$_dataPrefix$key');
    await prefs.remove('$_timePrefix$key');
  }

  // ── Cache key builders ────────────────────────────────────────
  static String topAnimeKey({
    int page = 1,
    String? type,
    String? filter,
    String? rating,
    String? orderBy,
    String? sort,
  }) =>
      'top_anime_p$page'
      '_t$type'
      '_f$filter'
      '_r$rating'
      '_o$orderBy'
      '_s$sort';

  static String searchKey(String query, int page) =>
      'search_${query.toLowerCase().trim()}_p$page';

  static String detailKey(int malId) => 'detail_$malId';
  static String charactersKey(int malId) => 'characters_$malId';
  static String staffKey(int malId) => 'staff_$malId';

  static String seasonalKey({
    int? year,
    String? season,
    int page = 1,
  }) =>
      'seasonal_${year ?? 'now'}_${season ?? 'now'}_p$page';

  static String genresKey() => 'genres';
  static String genreAnimeKey(int genreId, int page) =>
      'genre_${genreId}_p$page';
  static String scheduleKey(String day, int page) =>
      'schedule_${day}_p$page';
  static String recommendationsKey(int malId) => 'recs_$malId';
  static String topCharactersKey(int page) => 'top_chars_p$page';
  static String characterDetailKey(int malId) =>
      'char_detail_$malId';
}