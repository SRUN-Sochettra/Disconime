import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/providers/characters_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';
import '../helpers/mock_api_service.dart';

void main() {
  late CharactersProvider provider;
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
    provider = CharactersProvider(apiService: mockApi);
  });

  tearDown(() {
    provider.dispose();
    mockApi.reset();
  });

  group('fetchTopCharacters', () {
    test('starts in initial state', () {
      expect(provider.topCharactersState, FetchState.initial);
      expect(provider.topCharacters, isEmpty);
    });

    test('sets loaded state with results', () async {
      await provider.fetchTopCharacters();
      expect(provider.topCharactersState, FetchState.loaded);
      expect(provider.topCharacters, isNotEmpty);
      expect(mockApi.getTopCharactersCallCount, 1);
    });

    test('sets error state on failure', () async {
      mockApi.shouldThrow = true;
      await provider.fetchTopCharacters();
      expect(provider.topCharactersState, FetchState.error);
      expect(provider.topCharactersErrorMessage, isNotEmpty);
    });

    test('loads more and appends', () async {
      await provider.fetchTopCharacters();
      final first = provider.topCharacters.length;
      await provider.fetchTopCharacters(loadMore: true);
      expect(provider.topCharacters.length, first * 2);
      expect(provider.currentPage, 2);
    });

    test('does not load more when hasMore is false', () async {
      mockApi.returnEmpty = true;
      await provider.fetchTopCharacters();
      expect(provider.hasMore, isFalse);
      await provider.fetchTopCharacters(loadMore: true);
      expect(mockApi.getTopCharactersCallCount, 1);
    });

    test('refresh resets and re-fetches', () async {
      await provider.fetchTopCharacters();
      await provider.fetchTopCharacters(loadMore: true);
      expect(provider.currentPage, 2);
      await provider.fetchTopCharacters();
      expect(provider.currentPage, 1);
    });
  });

  group('fetchCharacterDetail', () {
    test('fetches and caches detail', () async {
      await provider.fetchCharacterDetail(17);
      expect(provider.detailStateFor(17), FetchState.loaded);
      expect(provider.detailFor(17), isNotNull);
      expect(provider.detailFor(17)!.name, isNotEmpty);
    });

    test('skips re-fetch when already loaded', () async {
      await provider.fetchCharacterDetail(17);
      await provider.fetchCharacterDetail(17);
      expect(mockApi.getCharacterDetailCallCount, 1);
    });

    test('sets error state on failure', () async {
      mockApi.shouldThrow = true;
      await provider.fetchCharacterDetail(17);
      expect(provider.detailStateFor(17), FetchState.error);
      expect(provider.detailErrorFor(17), isNotEmpty);
    });

    test('detailFor returns null before fetch', () {
      expect(provider.detailFor(99), isNull);
    });

    test('detailStateFor returns initial before fetch', () {
      expect(provider.detailStateFor(99), FetchState.initial);
    });
  });
}