import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_discovery/providers/favorites_provider.dart';
import '../helpers/test_data.dart';

void main() {
  late FavoritesProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    provider = FavoritesProvider();
    await provider.loadFavorites();
  });

  tearDown(() {
    provider.dispose();
  });

  // ── loadFavorites ─────────────────────────────────────────────
  group('loadFavorites', () {
    test('starts empty', () {
      expect(provider.favorites, isEmpty);
    });

    test('loads persisted favorites on init', () async {
      provider.toggleFavorite(TestData.naruto);
      await Future.delayed(Duration.zero);

      final newProvider = FavoritesProvider();
      await newProvider.loadFavorites();
      expect(newProvider.favorites.length, 1);
      expect(newProvider.favorites.first.malId, TestData.naruto.malId);
      newProvider.dispose();
    });
  });

  // ── toggleFavorite ────────────────────────────────────────────
  group('toggleFavorite', () {
    test('adds anime to favorites', () {
      provider.toggleFavorite(TestData.naruto);
      expect(provider.favorites.length, 1);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
    });

    test('removes anime from favorites when already favorited', () {
      provider.toggleFavorite(TestData.naruto);
      provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isFalse);
      expect(provider.favorites, isEmpty);
    });

    test('can add multiple anime', () {
      provider.toggleFavorite(TestData.naruto);
      provider.toggleFavorite(TestData.fmab);
      expect(provider.favorites.length, 2);
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

  // ── isFavorite ────────────────────────────────────────────────
  group('isFavorite', () {
    test('returns false for unknown malId', () {
      expect(provider.isFavorite(99999), isFalse);
    });

    test('returns true after adding', () {
      provider.toggleFavorite(TestData.naruto);
      expect(provider.isFavorite(TestData.naruto.malId), isTrue);
    });
  });

  // ── favorites getter cache ────────────────────────────────────
  group('favorites getter', () {
    test('returns consistent list reference when not mutated', () {
      provider.toggleFavorite(TestData.naruto);
      final list1 = provider.favorites;
      final list2 = provider.favorites;
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

  // ── filteredFavorites ─────────────────────────────────────────
  group('filteredFavorites', () {
    setUp(() {
      provider.toggleFavorite(TestData.naruto);    // TV, score 7.98
      provider.toggleFavorite(TestData.fmab);      // TV, score 9.10
      provider.toggleFavorite(TestData.animeMovie); // Movie, score 8.0
    });

    test('returns all when no filter active', () {
      expect(provider.filteredFavorites.length, 3);
    });

    test('filters by type TV', () {
      provider.updateFilter(type: 'tv');
      final result = provider.filteredFavorites;
      expect(result.every((a) => a.type?.toLowerCase() == 'tv'), isTrue);
      expect(result.length, 2);
    });

    test('filters by type Movie', () {
      provider.updateFilter(type: 'movie');
      final result = provider.filteredFavorites;
      expect(result.length, 1);
      expect(result.first.malId, TestData.animeMovie.malId);
    });

    test('empty type string shows all', () {
      provider.updateFilter(type: 'tv');
      provider.updateFilter(type: '');
      expect(provider.filteredFavorites.length, 3);
    });

    test('sorts by score descending', () {
      provider.updateFilter(orderBy: 'score');
      final result = provider.filteredFavorites;
      for (var i = 0; i < result.length - 1; i++) {
        expect(
          (result[i].score.value ?? 0) >= (result[i + 1].score.value ?? 0),
          isTrue,
        );
      }
    });

    test('sorts by title ascending', () {
      provider.updateFilter(orderBy: 'title');
      final result = provider.filteredFavorites;
      for (var i = 0; i < result.length - 1; i++) {
        expect(
          result[i].title.compareTo(result[i + 1].title) <= 0,
          isTrue,
        );
      }
    });

    test('date_added returns most recently added first', () {
      provider.updateFilter(orderBy: 'date_added');
      final result = provider.filteredFavorites;
      expect(result.first.malId, TestData.animeMovie.malId);
    });

    test('combined type + sort filter', () {
      provider.updateFilter(type: 'tv', orderBy: 'score');
      final result = provider.filteredFavorites;
      expect(result.every((a) => a.type?.toLowerCase() == 'tv'), isTrue);
      expect(
        (result.first.score.value ?? 0) >= (result.last.score.value ?? 0),
        isTrue,
      );
    });
  });

  // ── updateFilter ──────────────────────────────────────────────
  group('updateFilter', () {
    test('sets orderBy', () {
      provider.updateFilter(orderBy: 'score');
      expect(provider.activeFilter.orderBy, 'score');
    });

    test('sets type', () {
      provider.updateFilter(type: 'tv');
      expect(provider.activeFilter.type, 'tv');
    });

    test('empty type sets to null', () {
      provider.updateFilter(type: 'tv');
      provider.updateFilter(type: '');
      expect(provider.activeFilter.type, isNull);
    });

    test('notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.updateFilter(orderBy: 'score');
      expect(notified, isTrue);
    });
  });

  // ── clearFilters ──────────────────────────────────────────────
  group('clearFilters', () {
    test('resets to default filter', () {
      provider.updateFilter(type: 'tv', orderBy: 'score');
      provider.clearFilters();
      expect(provider.activeFilter.isActive, isFalse);
      expect(provider.activeFilter.orderBy, 'date_added');
      expect(provider.activeFilter.type, isNull);
    });

    test('notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.clearFilters();
      expect(notified, isTrue);
    });
  });

  // ── activeFilter ──────────────────────────────────────────────
  group('activeFilter', () {
    test('starts inactive', () {
      expect(provider.activeFilter.isActive, isFalse);
    });

    test('becomes active after updateFilter', () {
      provider.updateFilter(type: 'tv');
      expect(provider.activeFilter.isActive, isTrue);
    });

    test('becomes inactive after clearFilters', () {
      provider.updateFilter(type: 'tv');
      provider.clearFilters();
      expect(provider.activeFilter.isActive, isFalse);
    });
  });
}