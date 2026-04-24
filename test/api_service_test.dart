import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:anime_discovery/services/api_service.dart';
import 'package:anime_discovery/models/anime_model.dart';

void main() {
  group('ApiService Tests', () {
    test('getTopAnime returns list of Anime on success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/top/anime')) {
          final response = {
            'data': [
              {
                'mal_id': 1,
                'title': 'Test Anime',
                'images': {
                  'jpg': {'image_url': 'https://example.com/image.jpg'}
                },
                'score': 9.5,
                'synopsis': 'A test anime synopsis.',
                'genres': []
              }
            ]
          };
          return http.Response(json.encode(response), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: mockClient);
      final result = await apiService.getTopAnime();

      expect(result, isA<List<Anime>>());
      expect(result.length, 1);
      expect(result[0].malId, 1);
      expect(result[0].title, 'Test Anime');
    });

    test('getTopAnime throws exception on error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: mockClient);

      expect(apiService.getTopAnime(), throwsException);
    });
  });
}
