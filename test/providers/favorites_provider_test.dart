import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_discovery/providers/favorites_provider.dart';
import '../helpers/test_data.dart';

void main() {
  late FavoritesProvider provider;

  setUp(() async {
    // Use in-memory SharedPreferences for tests.
    SharedPreferences.setMockInitialValues({});
    provider = FavoritesProvider();
    await provider.loadFavorites();
  });

  tearDown(() {
    provider.dispose();
  });

  group('loadFavorites', () {
    test('starts empty', () {
      expect(provider.favorites, isEmpty);
    });

    test('loads persisted favorites on init', () async {
      await provider.toggleFavorite(TestData.naruto);

      final newProvider = FavoritesProvider();
      await newProvider.loadFavorites();

      expect(newProvider.favorites.length, 1);
      expect(newProvider.favorites.first.malId, TestData.naruto.malId);
      newProvider.dispose();
    });
  });

  group('toggleFavorite', () {
    test('adds anime to favorites', () async {
      await provider.toggleFavorite(TestData.naruto);

      expect(provider.favorites.length, 1);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
    });

    test('removes anime from favorites when already favorited', () async {
      await provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);

      await provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isFalse);
      expect(provider.favorites, isEmpty);
    });

    test('can add multiple anime', () async {
      await provider.toggleFavorite(TestData.naruto);
      await provider.toggleFavorite(TestData.fmab);

      expect(provider.favorites.length, 2);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
      expect(provider.isFavorite(TestData.fmab.malId), isTrue);
    });

    test('persists changes to SharedPreferences', () async {
      await provider.toggleFavorite(TestData.naruto);

      final newProvider = FavoritesProvider();
      await newProvider.loadFavorites();

      expect(newProvider.isFavorite(TestData.naruto.malId), isTrue);
      newProvider.dispose();
    });

    test('persists removal to SharedPreferences', () async {
      await provider.toggleFavorite(TestData.naruto);
      await provider.toggleFavorite(TestData.naruto);

      final newProvider = FavoritesProvider();
      await newProvider.loadFavorites();

      expect(newProvider.isFavorite(TestData.naruto.malId), isFalse);
      newProvider.dispose();
    });
  });

  group('isFavorite', () {
    test('returns false for unknown malId', () {
      expect(provider.isFavorite(99999), isFalse);
    });

    test('returns true after adding', () async {
      await provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
    });
  });

  group('favorites getter', () {
    test('returns consistent list reference when not mutated', () async {
      await provider.toggleFavorite(TestData.naruto);

      final list1 = provider.favorites;
      final list2 = provider.favorites;

      // Cache should return same list instance.
      expect(identical(list1, list2), isTrue);
    });

    test('invalidates cache after mutation', () async {
      await provider.toggleFavorite(TestData.naruto);
      final list1 = provider.favorites;

      await provider.toggleFavorite(TestData.fmab);
      final list2 = provider.favorites;

      expect(identical(list1, list2), isFalse);
    });
  });
}