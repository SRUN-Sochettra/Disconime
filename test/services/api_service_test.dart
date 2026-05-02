import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_discovery/services/api_service.dart';
import 'package:anime_discovery/services/connectivity_service.dart';
import 'package:anime_discovery/services/cache_service.dart';
import '../helpers/test_data.dart';

http.Client _mockClient(Map<String, dynamic> body, {int statusCode = 200}) {
  return MockClient((_) async => http.Response(
    json.encode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  ));
}

http.Client _errorClient(int code) {
  return MockClient((_) async => http.Response('Error', code));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ApiService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.instance.clearAll();
    ConnectivityService.instance.setMockOnline(true);
  });

  // ── getTopAnime ───────────────────────────────────────────────
  group('getTopAnime', () {
    test('parses response correctly', () async {
      service = ApiService(client: _mockClient(TestData.apiListResponse));
      final results = await service.getTopAnime();
      expect(results.length, 2);
      expect(results.first.title, 'Naruto');
    });

    test('returns empty list for empty response', () async {
      service = ApiService(client: _mockClient(TestData.apiEmptyResponse));
      final results = await service.getTopAnime();
      expect(results, isEmpty);
    });

    test('throws on non-200 status', () async {
      service = ApiService(client: _errorClient(500));
      expect(() => service.getTopAnime(), throwsException);
    });

    test('throws on 404 status', () async {
      service = ApiService(client: _errorClient(404));
      expect(() => service.getTopAnime(), throwsException);
    });
  });

  // ── searchAnime ───────────────────────────────────────────────
  group('searchAnime', () {
    test('parses results correctly', () async {
      service = ApiService(client: _mockClient(TestData.apiListResponse));
      final results = await service.searchAnime('naruto');
      expect(results, isNotEmpty);
      expect(results.first.malId, 20);
    });

    test('returns empty list for empty response', () async {
      service = ApiService(client: _mockClient(TestData.apiEmptyResponse));
      final results = await service.searchAnime('zzz');
      expect(results, isEmpty);
    });
  });

  // ── searchAnime with filter params ────────────────────────────
  group('searchAnime with filters', () {
    test('passes type param in query', () async {
      Uri? capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          json.encode(TestData.apiListResponse),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      service = ApiService(client: client);
      await service.searchAnime('naruto', type: 'tv');
      expect(capturedUri?.queryParameters['type'], 'tv');
    });

    test('passes status param in query', () async {
      Uri? capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          json.encode(TestData.apiListResponse),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      service = ApiService(client: client);
      await service.searchAnime('naruto', status: 'airing');
      expect(capturedUri?.queryParameters['status'], 'airing');
    });

    test('passes orderBy and sort params in query', () async {
      Uri? capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          json.encode(TestData.apiListResponse),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      service = ApiService(client: client);
      await service.searchAnime('naruto', orderBy: 'score', sort: 'desc');
      expect(capturedUri?.queryParameters['order_by'], 'score');
      expect(capturedUri?.queryParameters['sort'], 'desc');
    });

    test('omits null params from query', () async {
      Uri? capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          json.encode(TestData.apiListResponse),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      service = ApiService(client: client);
      await service.searchAnime('naruto');
      expect(capturedUri?.queryParameters.containsKey('type'), isFalse);
      expect(capturedUri?.queryParameters.containsKey('status'), isFalse);
    });
  });

  // ── getAnimeDetails ───────────────────────────────────────────
  group('getAnimeDetails', () {
    test('parses single anime correctly', () async {
      service = ApiService(client: _mockClient(TestData.apiDetailResponse));
      final anime = await service.getAnimeDetails(20);
      expect(anime.malId, 20);
      expect(anime.title, 'Naruto');
    });
  });

  // ── getGenres ─────────────────────────────────────────────────
  group('getGenres', () {
    test('parses genres correctly', () async {
      service = ApiService(client: _mockClient(TestData.genresResponse));
      final genres = await service.getGenres();
      expect(genres.length, 1);
      expect(genres.first['name'], 'Action');
      expect(genres.first['count'], 5000);
    });
  });

  // ── retry logic ───────────────────────────────────────────────
  group('retry logic', () {
    test('retries on 429 and eventually throws', () async {
      var callCount = 0;
      final retryClient = MockClient((_) async {
        callCount++;
        return http.Response(
          'Rate Limited',
          429,
          headers: {'retry-after': '0'},
        );
      });
      service = ApiService(client: retryClient);
      await expectLater(() => service.getTopAnime(), throwsException);
      expect(callCount, greaterThan(1));
    });
  });
}