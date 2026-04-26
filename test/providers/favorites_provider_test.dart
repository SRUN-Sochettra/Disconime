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
      provider.toggleFavorite(TestData.naruto);
      // Let the microtask-based persist flush to SharedPreferences.
      await Future.delayed(Duration.zero);

      final newProvider = FavoritesProvider();
      await newProvider.loadFavorites();

      expect(newProvider.favorites.length, 1);
      expect(newProvider.favorites.first.malId, TestData.naruto.malId);
      newProvider.dispose();
    });
  });

  group('toggleFavorite', () {
    test('adds anime to favorites', () {
      provider.toggleFavorite(TestData.naruto);

      expect(provider.favorites.length, 1);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
    });

    test('removes anime from favorites when already favorited', () {
      provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);

      provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isFalse);
      expect(provider.favorites, isEmpty);
    });

    test('can add multiple anime', () {
      provider.toggleFavorite(TestData.naruto);
      provider.toggleFavorite(TestData.fmab);

      expect(provider.favorites.length, 2);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
      expect(provider.isFavorite(TestData.fmab.malId), isTrue);
    });

    test('persists changes to SharedPreferences', () async {
      provider.toggleFavorite(TestData.naruto);
      await Future.delayed(Duration.zero);

      final newProvider = FavoritesProvider();
      await newProvider.loadFavorites();

      expect(newProvider.isFavorite(TestData.naruto.malId), isTrue);
      newProvider.dispose();
    });

    test('persists removal to SharedPreferences', () async {
      provider.toggleFavorite(TestData.naruto);
      await Future.delayed(Duration.zero);
      provider.toggleFavorite(TestData.naruto);
      await Future.delayed(Duration.zero);

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

    test('returns true after adding', () {
      provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
    });
  });

  group('favorites getter', () {
    test('returns consistent list reference when not mutated', () {
      provider.toggleFavorite(TestData.naruto);

      final list1 = provider.favorites;
      final list2 = provider.favorites;

      // Cache should return same list instance.
      expect(identical(list1, list2), isTrue);
    });

    test('invalidates cache after mutation', () {
      provider.toggleFavorite(TestData.naruto);
      final list1 = provider.favorites;

      provider.toggleFavorite(TestData.fmab);
      final list2 = provider.favorites;

      expect(identical(list1, list2), isFalse);
    });
  });
}