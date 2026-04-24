import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/anime_model.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  String get baseUrl {
    try {
      return dotenv.env['JIKAN_API_URL'] ?? 'https://api.jikan.moe/v4';
    } catch (_) {
      return 'https://api.jikan.moe/v4';
    }
  }

  Future<List<Anime>> getTopAnime({int page = 1}) async {
    final response = await client.get(Uri.parse('$baseUrl/top/anime?page=$page'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> animeList = data['data'];
      return animeList.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top anime');
    }
  }

  Future<List<Anime>> searchAnime(String query, {int page = 1}) async {
    final response = await client.get(Uri.parse('$baseUrl/anime?q=$query&page=$page'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> animeList = data['data'];
      return animeList.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search anime');
    }
  }

  Future<Anime> getAnimeDetails(int id) async {
    final response = await client.get(Uri.parse('$baseUrl/anime/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Anime.fromJson(data['data']);
    } else {
      throw Exception('Failed to load anime details');
    }
  }

  Future<List<Anime>> getAnimeRecommendations(int malId, {int page = 1}) async {
    final response = await client.get(Uri.parse('$baseUrl/anime/$malId/recommendations?page=$page'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      final List<dynamic> recData = decodedData['data'] ?? [];
      
      return recData.map((json) {
        final entry = json['entry'];
        return Anime(
          malId: entry['mal_id'] ?? 0,
          title: entry['title'] ?? '',
          imageUrl: entry['images']?['jpg']?['large_image_url'] ?? entry['images']?['jpg']?['image_url'] ?? '',
          score: Score(),
          synopsis: Synopsis(text: ''),
          genres: [],
        );
      }).toList();
    } else {
      throw Exception('Failed to load recommendations');
    }
  }
}
