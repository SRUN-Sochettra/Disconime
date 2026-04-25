import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/anime_model.dart';

class ApiService {
  final http.Client client;

  static const Duration _minRequestInterval = Duration(milliseconds: 400);
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

  ApiService({http.Client? client}) : client = client ?? http.Client();

  String get baseUrl {
    try {
      return dotenv.env['JIKAN_API_URL'] ?? 'https://api.jikan.moe/v4';
    } catch (_) {
      return 'https://api.jikan.moe/v4';
    }
  }

  Future<void> _throttle() async {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRequestTime);
    if (elapsed < _minRequestInterval) {
      await Future.delayed(_minRequestInterval - elapsed);
    }
    _lastRequestTime = DateTime.now();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    await _throttle();
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again shortly.');
      } else {
        throw Exception('Request failed with status ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('[ApiService] Error fetching $uri: $e');
      rethrow;
    }
  }

  Future<List<Anime>> getTopAnime({
    int page = 1,
    String? type,
    String? filter,
    String? rating,
    String? orderBy,
    String? sort,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
    };

    if (type != null && type.isNotEmpty) params['type'] = type;
    if (filter != null && filter.isNotEmpty) params['filter'] = filter;
    if (rating != null && rating.isNotEmpty) params['rating'] = rating;
    if (orderBy != null && orderBy.isNotEmpty) params['order_by'] = orderBy;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;

    final uri = Uri.parse('$baseUrl/top/anime').replace(queryParameters: params);
    final data = await _getJson(uri);
    final List<dynamic> animeList = data['data'] ?? [];
    return animeList
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Anime>> searchAnime(String query, {int page = 1}) async {
    final encoded = Uri.encodeComponent(query);
    final data =
        await _getJson(Uri.parse('$baseUrl/anime?q=$encoded&page=$page'));
    final List<dynamic> animeList = data['data'] ?? [];
    return animeList
        .map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Anime> getAnimeDetails(int id) async {
    final data = await _getJson(Uri.parse('$baseUrl/anime/$id'));
    return Anime.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<Anime>> getAnimeRecommendations(int malId) async {
    final data = await _getJson(
      Uri.parse('$baseUrl/anime/$malId/recommendations'),
    );

    final List<dynamic> recData = data['data'] ?? [];
    final List<Anime> results = [];

    for (final item in recData) {
      try {
        final map = item as Map<String, dynamic>;
        final entry = map['entry'] as Map<String, dynamic>?;

        if (entry == null) {
          debugPrint('[ApiService] skipping rec — entry is null');
          continue;
        }

        final images = entry['images'] as Map<String, dynamic>?;
        final jpg = images?['jpg'] as Map<String, dynamic>?;

        results.add(Anime(
          malId: entry['mal_id'] as int? ?? 0,
          title: entry['title'] as String? ?? '',
          imageUrl: jpg?['large_image_url'] as String? ??
              jpg?['image_url'] as String? ??
              '',
          score: const Score(),
          synopsis: const Synopsis(text: ''),
          genres: const [],
        ));
      } catch (e, stack) {
        debugPrint('[ApiService] failed to parse rec entry: $e\n$stack');
        continue;
      }
    }

    return results;
  }
}