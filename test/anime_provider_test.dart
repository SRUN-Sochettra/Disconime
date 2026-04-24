import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/services/api_service.dart';
import 'package:anime_discovery/models/anime_model.dart';

class FakeApiService extends ApiService {
  bool shouldThrow = false;
  
  @override
  Future<List<Anime>> getTopAnime({int page = 1}) async {
    if (shouldThrow) {
      throw Exception('Fake error');
    }
    return [
      Anime(
        malId: page, // Use page as ID to verify pagination
        title: 'Top Anime $page',
        imageUrl: '',
        score: Score(value: 9.0),
        synopsis: Synopsis(text: 'Synopsis'),
        genres: [],
      )
    ];
  }

  @override
  Future<List<Anime>> searchAnime(String query, {int page = 1}) async {
    if (shouldThrow) {
      throw Exception('Fake error');
    }
    return [
      Anime(
        malId: page,
        title: 'Search Result $query - $page',
        imageUrl: '',
        score: Score(value: 8.5),
        synopsis: Synopsis(text: 'Synopsis'),
        genres: [],
      )
    ];
  }
}

void main() {
  group('AnimeProvider Tests', () {
    late AnimeProvider provider;
    late FakeApiService fakeApiService;

    setUp(() {
      fakeApiService = FakeApiService();
      provider = AnimeProvider(apiService: fakeApiService);
    });

    test('fetchTopAnime success sets state to loaded and updates list', () async {
      expect(provider.topAnimeState, FetchState.initial);
      expect(provider.topAnime, isEmpty);

      await provider.fetchTopAnime();

      expect(provider.topAnimeState, FetchState.loaded);
      expect(provider.topAnime.length, 1);
      expect(provider.topAnime[0].title, 'Top Anime 1');
    });

    test('fetchTopAnime with loadMore appends to list', () async {
      await provider.fetchTopAnime();
      expect(provider.topAnime.length, 1);

      await provider.fetchTopAnime(loadMore: true);
      
      expect(provider.topAnimeState, FetchState.loaded);
      expect(provider.topAnime.length, 2);
      expect(provider.topAnime[1].title, 'Top Anime 2');
    });

    test('fetchTopAnime failure sets state to error', () async {
      fakeApiService.shouldThrow = true;
      
      await provider.fetchTopAnime();

      expect(provider.topAnimeState, FetchState.error);
      expect(provider.errorMessage, contains('Fake error'));
    });

    test('searchAnime with empty query resets state', () async {
      await provider.searchAnime('Naruto');
      expect(provider.searchResults, isNotEmpty);

      await provider.searchAnime('');
      expect(provider.searchState, FetchState.initial);
      expect(provider.searchResults, isEmpty);
    });
  });
}
