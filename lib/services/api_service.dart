import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/anime_model.dart';
import '../models/schedule_model.dart';
import '../models/character_model.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import '../widgets/global_error_handler.dart';

class ApiService {
  final http.Client client;
  final CacheService _cache = CacheService.instance;

  static const Duration _minRequestInterval = Duration(milliseconds: 400);
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  static const int _maxRetries = 3;

  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);
  Future<void> _requestQueue = Future.value();

  ApiService({http.Client? client}) : client = client ?? http.Client();

  String get baseUrl {
    try {
      return dotenv.env['JIKAN_API_URL'] ?? 'https://api.jikan.moe/v4';
    } catch (_) {
      return 'https://api.jikan.moe/v4';
    }
  }

  bool get _isOnline => ConnectivityService.instance.isOnline;

  // ── Throttle ──────────────────────────────────────────────────
  Future<T> _throttle<T>(Future<T> Function() action) {
    final previousRequest = _requestQueue;
    final releaseQueue = Completer<void>();
    _requestQueue = releaseQueue.future;

    return previousRequest
        .then((_) async {
          final now = DateTime.now();
          final elapsed = now.difference(_lastRequestTime);
          if (elapsed < _minRequestInterval) {
            await Future.delayed(_minRequestInterval - elapsed);
          }
          _lastRequestTime = DateTime.now();
          return action();
        })
        .whenComplete(() {
          if (!releaseQueue.isCompleted) releaseQueue.complete();
        });
  }

  bool _shouldRetry(http.Response response) =>
      response.statusCode == 429 || response.statusCode >= 500;

  Duration _retryDelayFor(http.Response response, int attempt) {
    final exponentialDelay = Duration(
      milliseconds: _baseRetryDelay.inMilliseconds * (1 << attempt),
    );
    final retryAfterHeader = response.headers['retry-after'];
    final retryAfterSeconds = int.tryParse(retryAfterHeader ?? '');
    if (retryAfterSeconds == null) return exponentialDelay;
    final retryAfterDelay = Duration(seconds: retryAfterSeconds);
    return retryAfterDelay > exponentialDelay
        ? retryAfterDelay
        : exponentialDelay;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      return await _throttle(() async {
        for (var attempt = 0; attempt <= _maxRetries; attempt++) {
          final response = await client.get(uri);

          if (response.statusCode == 200) {
            return json.decode(response.body) as Map<String, dynamic>;
          }

          if (_shouldRetry(response) && attempt < _maxRetries) {
            final delay = _retryDelayFor(response, attempt);
            debugPrint(
              '[ApiService] Retrying $uri after status '
              '${response.statusCode} in ${delay.inMilliseconds}ms '
              '(attempt ${attempt + 1}/$_maxRetries).',
            );
            await Future.delayed(delay);
            continue;
          }

          if (response.statusCode == 429) {
            throw Exception(
              'Rate limit exceeded after retries. '
              'Please try again shortly.',
            );
          }

          throw Exception(
            'Request failed with status ${response.statusCode}.',
          );
        }
        throw Exception('Request failed after retries.');
      });
    } catch (e, stack) {
      debugPrint('[ApiService] Error fetching $uri: $e');
      GlobalErrorHandler.reportError(e, stack);
      rethrow;
    }
  }

  // ── Cached fetch helper ───────────────────────────────────────
  /// Tries to serve from cache first.
  /// Falls back to network if cache is empty/expired and online.
  /// Falls back to stale cache if offline.
  Future<Map<String, dynamic>> _getCached(
    Uri uri,
    String cacheKey, {
    required Duration ttl,
  }) async {
    // 1. Try fresh cache.
    final cached = await _cache.get(cacheKey, ttl: ttl);
    if (cached != null) {
      debugPrint('[ApiService] Cache hit: $cacheKey');
      return cached as Map<String, dynamic>;
    }

    // 2. Offline — try stale cache (any age).
    if (!_isOnline) {
      final stale = await _cache.get(
        cacheKey,
        ttl: const Duration(days: 365),
      );
      if (stale != null) {
        debugPrint('[ApiService] Serving stale cache (offline): $cacheKey');
        return stale as Map<String, dynamic>;
      }
      throw Exception(
        'No internet connection and no cached data available.',
      );
    }

    // 3. Fetch from network and store in cache.
    final data = await _getJson(uri);
    await _cache.set(cacheKey, data);
    return data;
  }

  // ── Top Anime ─────────────────────────────────────────────────
  Future<List<Anime>> getTopAnime({
    int page = 1,
    String? type,
    String? filter,
    String? rating,
    String? orderBy,
    String? sort,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (filter != null && filter.isNotEmpty) params['filter'] = filter;
    if (rating != null && rating.isNotEmpty) params['rating'] = rating;
    if (orderBy != null && orderBy.isNotEmpty) params['order_by'] = orderBy;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;

    final uri =
        Uri.parse('$baseUrl/top/anime').replace(queryParameters: params);
    final cacheKey = CacheService.topAnimeKey(
      page: page,
      type: type,
      filter: filter,
      rating: rating,
      orderBy: orderBy,
      sort: sort,
    );

    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.topAnimeTtl,
    );
    final List<dynamic> animeList = data['data'] ?? [];
    return animeList
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ── Search ────────────────────────────────────────────────────
  Future<List<Anime>> searchAnime(String query, {int page = 1}) async {
    final uri = Uri.parse('$baseUrl/anime').replace(
      queryParameters: {'q': query, 'page': page.toString()},
    );
    final cacheKey = CacheService.searchKey(query, page);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.searchTtl,
    );
    final List<dynamic> animeList = data['data'] ?? [];
    return animeList
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ── Anime Detail ──────────────────────────────────────────────
  Future<Anime> getAnimeDetails(int id) async {
    final uri = Uri.parse('$baseUrl/anime/$id/full');
    final cacheKey = CacheService.detailKey(id);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.detailTtl,
    );
    return Anime.fromJson(data['data'] as Map<String, dynamic>);
  }

  // ── Anime Characters ──────────────────────────────────────────
  Future<List<AnimeCharacter>> getAnimeCharacters(int malId) async {
    final uri = Uri.parse('$baseUrl/anime/$malId/characters');
    final cacheKey = CacheService.charactersKey(malId);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.charactersTtl,
    );
    final List<dynamic> characters = data['data'] ?? [];
    final List<AnimeCharacter> results = [];
    for (final item in characters) {
      try {
        results.add(AnimeCharacter.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('[ApiService] failed to parse character: $e');
      }
    }
    results.sort((a, b) => (b.favorites ?? 0).compareTo(a.favorites ?? 0));
    return results;
  }

  // ── Anime Staff ───────────────────────────────────────────────
  Future<List<AnimeStaff>> getAnimeStaff(int malId) async {
    final uri = Uri.parse('$baseUrl/anime/$malId/staff');
    final cacheKey = CacheService.staffKey(malId);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.staffTtl,
    );
    final List<dynamic> staff = data['data'] ?? [];
    final List<AnimeStaff> results = [];
    for (final item in staff) {
      try {
        results.add(AnimeStaff.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('[ApiService] failed to parse staff: $e');
      }
    }
    return results;
  }

  // ── Recommendations ───────────────────────────────────────────
  Future<List<Anime>> getAnimeRecommendations(int malId) async {
    final uri = Uri.parse('$baseUrl/anime/$malId/recommendations');
    final cacheKey = CacheService.recommendationsKey(malId);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.recommendationsTtl,
    );
    final List<dynamic> recData = data['data'] ?? [];
    final List<Anime> results = [];
    for (final item in recData) {
      try {
        final map = item as Map<String, dynamic>;
        final entry = map['entry'] as Map<String, dynamic>?;
        if (entry == null) continue;
        final images = entry['images'] as Map<String, dynamic>?;
        final jpg = images?['jpg'] as Map<String, dynamic>?;
        results.add(
          Anime(
            malId: entry['mal_id'] as int? ?? 0,
            title: entry['title'] as String? ?? '',
            imageUrl: jpg?['large_image_url'] as String? ??
                jpg?['image_url'] as String? ??
                '',
            score: const Score(),
            synopsis: const Synopsis(text: 'No synopsis available.'),
            genres: const [],
          ),
        );
      } catch (e, stack) {
        debugPrint('[ApiService] failed to parse rec entry: $e\n$stack');
      }
    }
    return results;
  }

  // ── Seasonal ──────────────────────────────────────────────────
  Future<List<Anime>> getSeasonNow({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/seasons/now').replace(
      queryParameters: {'page': page.toString()},
    );
    final cacheKey = CacheService.seasonalKey(page: page);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.seasonalTtl,
    );
    final List<dynamic> animeList = data['data'] ?? [];
    return animeList
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Anime>> getSeason(
    int year,
    String season, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$baseUrl/seasons/$year/$season').replace(
      queryParameters: {'page': page.toString()},
    );
    final cacheKey = CacheService.seasonalKey(
      year: year,
      season: season,
      page: page,
    );
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.seasonalTtl,
    );
    final List<dynamic> animeList = data['data'] ?? [];
    return animeList
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ── Genres ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getGenres() async {
    final uri = Uri.parse('$baseUrl/genres/anime');
    final cacheKey = CacheService.genresKey();
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.genresTtl,
    );
    final List<dynamic> genres = data['data'] ?? [];
    return genres.cast<Map<String, dynamic>>();
  }

  Future<List<Anime>> getAnimeByGenre(int genreId, {int page = 1}) async {
    final uri = Uri.parse('$baseUrl/anime').replace(
      queryParameters: {
        'genres': genreId.toString(),
        'order_by': 'score',
        'sort': 'desc',
        'page': page.toString(),
      },
    );
    final cacheKey = CacheService.genreAnimeKey(genreId, page);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.genreAnimeTtl,
    );
    final List<dynamic> animeList = data['data'] ?? [];
    return animeList
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ── Schedule ──────────────────────────────────────────────────
  Future<List<ScheduleEntry>> getSchedule(
    BroadcastDay day, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$baseUrl/schedules').replace(
      queryParameters: {
        'filter': day.apiValue,
        'page': page.toString(),
        'kids': 'false',
      },
    );
    final cacheKey = CacheService.scheduleKey(day.apiValue, page);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.scheduleTtl,
    );
    final List<dynamic> animeList = data['data'] ?? [];
    final List<ScheduleEntry> results = [];
    for (final item in animeList) {
      try {
        results.add(ScheduleEntry.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('[ApiService] failed to parse schedule entry: $e');
      }
    }
    results.sort((a, b) {
      final at = a.timeOfDay;
      final bt = b.timeOfDay;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return (at.hour * 60 + at.minute)
          .compareTo(bt.hour * 60 + bt.minute);
    });
    return results;
  }

  // ── Top Characters ────────────────────────────────────────────
  Future<List<TopCharacter>> getTopCharacters({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/top/characters').replace(
      queryParameters: {'page': page.toString()},
    );
    final cacheKey = CacheService.topCharactersKey(page);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.topCharactersTtl,
    );
    final List<dynamic> characters = data['data'] ?? [];
    final List<TopCharacter> results = [];
    for (final item in characters) {
      try {
        results.add(TopCharacter.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('[ApiService] failed to parse top character: $e');
      }
    }
    return results;
  }

  // ── Character Detail ──────────────────────────────────────────
  Future<Character> getCharacterDetail(int malId) async {
    final uri = Uri.parse('$baseUrl/characters/$malId/full');
    final cacheKey = CacheService.characterDetailKey(malId);
    final data = await _getCached(
      uri,
      cacheKey,
      ttl: CacheService.characterDetailTtl,
    );
    return Character.fromJson(data['data'] as Map<String, dynamic>);
  }
}