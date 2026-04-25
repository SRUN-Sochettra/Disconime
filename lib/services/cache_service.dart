import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A lightweight key-value cache backed by [SharedPreferences].
///
/// Each entry stores:
/// - The serialised JSON string
/// - A timestamp used to enforce [ttl] expiry
///
/// Usage:
/// ```dart
/// // Write
/// await CacheService.instance.set('top_anime_p1', jsonData);
///
/// // Read (returns null if missing or expired)
/// final cached = await CacheService.instance.get('top_anime_p1');
/// ```
class CacheService {
  CacheService._();

  static final CacheService instance = CacheService._();

  // ── Key prefixes ──────────────────────────────────────────────
  static const String _dataPrefix = 'cache_data_';
  static const String _timePrefix = 'cache_time_';

  // ── Default TTLs ──────────────────────────────────────────────
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
    } catch (e) {
      debugPrint('[CacheService] Failed to write $key: $e');
    }
  }

  // ── Read ──────────────────────────────────────────────────────
  /// Returns the cached value for [key] if it exists and has not
  /// exceeded [ttl]. Returns null otherwise.
  Future<dynamic> get(String key, {required Duration ttl}) async {
    try {
      final prefs = await _getPrefs();
      final timestamp = prefs.getInt('$_timePrefix$key');
      if (timestamp == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > ttl.inMilliseconds) {
        // Expired — clean up silently.
        await _delete(prefs, key);
        return null;
      }

      final encoded = prefs.getString('$_dataPrefix$key');
      if (encoded == null) return null;

      return json.decode(encoded);
    } catch (e) {
      debugPrint('[CacheService] Failed to read $key: $e');
      return null;
    }
  }

  // ── Invalidate ────────────────────────────────────────────────
  Future<void> invalidate(String key) async {
    try {
      final prefs = await _getPrefs();
      await _delete(prefs, key);
    } catch (e) {
      debugPrint('[CacheService] Failed to invalidate $key: $e');
    }
  }

  /// Removes all cache entries.
  Future<void> clearAll() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_dataPrefix) || key.startsWith(_timePrefix)) {
          await prefs.remove(key);
        }
      }
      debugPrint('[CacheService] All cache cleared.');
    } catch (e) {
      debugPrint('[CacheService] Failed to clear cache: $e');
    }
  }

  Future<void> _delete(SharedPreferences prefs, String key) async {
    await prefs.remove('$_dataPrefix$key');
    await prefs.remove('$_timePrefix$key');
  }

  // ── Cache key builders ────────────────────────────────────────
  // Centralised so every call site uses the same key format.

  static String topAnimeKey({
    int page = 1,
    String? type,
    String? filter,
    String? rating,
    String? orderBy,
    String? sort,
  }) =>
      // ignore: unnecessary_brace_in_string_interps
      'top_anime_p${page}_t${type}_f${filter}_r${rating}'
      // ignore: unnecessary_brace_in_string_interps
      '_o${orderBy}_s${sort}';

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

  static String characterDetailKey(int malId) => 'char_detail_$malId';
}