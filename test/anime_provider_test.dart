import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/models/anime_model.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/services/api_service.dart';

class FakeApiService extends ApiService {
  @override
  Future<List<Anime>> getTopAnime({
    int page = 1,
    String? type,
    String? filter,
    String? rating,
    String? orderBy,
    String? sort,
  }) async {
    return [
      const Anime(
        malId: 1,
        title: 'Test Anime',
        imageUrl: '',
        score: Score(value: 9.0),
        synopsis: Synopsis(text: ''),
        genres: [],
      ),
    ];
  }
}

void main() {
  test('fetchTopAnime populates topAnime list', () async {
    final provider = AnimeProvider(apiService: FakeApiService());
    await provider.fetchTopAnime();
    expect(provider.topAnime.length, 1);
    expect(provider.topAnime.first.title, 'Test Anime');
    expect(provider.topAnimeState, FetchState.loaded);
  });
}