import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/models/filter_model.dart';

void main() {
  // ── AnimeFilter ───────────────────────────────────────────────
  group('AnimeFilter', () {
    test('default constructor creates empty filter', () {
      const filter = AnimeFilter();
      expect(filter.type, isNull);
      expect(filter.filter, isNull);
      expect(filter.rating, isNull);
      expect(filter.orderBy, isNull);
      expect(filter.sort, isNull);
    });

    group('isActive', () {
      test('returns false for empty filter', () {
        expect(const AnimeFilter().isActive, isFalse);
      });

      test('returns true when type is set', () {
        expect(const AnimeFilter(type: 'tv').isActive, isTrue);
      });

      test('returns true when filter is set', () {
        expect(const AnimeFilter(filter: 'airing').isActive, isTrue);
      });

      test('returns true when rating is set', () {
        expect(const AnimeFilter(rating: 'pg').isActive, isTrue);
      });

      test('returns true when orderBy is set', () {
        expect(const AnimeFilter(orderBy: 'score').isActive, isTrue);
      });

      test('sort alone does not make filter active', () {
        expect(const AnimeFilter(sort: 'desc').isActive, isFalse);
      });
    });

    group('activeCount', () {
      test('returns 0 for empty filter', () {
        expect(const AnimeFilter().activeCount, 0);
      });

      test('counts each active field', () {
        const filter = AnimeFilter(
          type: 'tv',
          filter: 'airing',
          rating: 'pg',
          orderBy: 'score',
          sort: 'desc', // should NOT count
        );
        expect(filter.activeCount, 4);
      });

      test('sort is excluded from count', () {
        expect(const AnimeFilter(sort: 'asc').activeCount, 0);
      });
    });

    group('copyWith', () {
      test('copies all fields when no overrides', () {
        const original = AnimeFilter(type: 'tv', filter: 'airing');
        final copy = original.copyWith();
        expect(copy.type, 'tv');
        expect(copy.filter, 'airing');
      });

      test('overrides specified field', () {
        const original = AnimeFilter(type: 'tv', filter: 'airing');
        final copy = original.copyWith(type: () => 'movie');
        expect(copy.type, 'movie');
        expect(copy.filter, 'airing');
      });

      test('sets field to null when override returns null', () {
        const original = AnimeFilter(type: 'tv');
        final copy = original.copyWith(type: () => null);
        expect(copy.type, isNull);
      });
    });

    group('equality', () {
      test('two empty filters are equal', () {
        expect(const AnimeFilter(), equals(const AnimeFilter()));
      });

      test('filters with same fields are equal', () {
        const a = AnimeFilter(type: 'tv', filter: 'airing');
        const b = AnimeFilter(type: 'tv', filter: 'airing');
        expect(a, equals(b));
      });

      test('filters with different fields are not equal', () {
        const a = AnimeFilter(type: 'tv');
        const b = AnimeFilter(type: 'movie');
        expect(a, isNot(equals(b)));
      });

      test('hashCode matches for equal filters', () {
        const a = AnimeFilter(type: 'tv', sort: 'desc');
        const b = AnimeFilter(type: 'tv', sort: 'desc');
        expect(a.hashCode, b.hashCode);
      });
    });
  });

  // ── CharacterSortOption ───────────────────────────────────────
  group('CharacterSortOption', () {
    test('all options have non-empty labels', () {
      for (final option in CharacterSortOption.values) {
        expect(option.label, isNotEmpty);
      }
    });

    test('all options have icons', () {
      for (final option in CharacterSortOption.values) {
        expect(option.icon, isNotNull);
      }
    });

    test('favoritesDesc label', () {
      expect(CharacterSortOption.favoritesDesc.label, 'Most Favorited');
    });

    test('favoritesAsc label', () {
      expect(CharacterSortOption.favoritesAsc.label, 'Least Favorited');
    });

    test('nameAsc label', () {
      expect(CharacterSortOption.nameAsc.label, 'Name A\u2192Z');
    });

    test('nameDesc label', () {
      expect(CharacterSortOption.nameDesc.label, 'Name Z\u2192A');
    });

    test('has exactly 4 options', () {
      expect(CharacterSortOption.values.length, 4);
    });
  });

  // ── FavoritesActiveFilter ─────────────────────────────────────
  group('FavoritesActiveFilter', () {
    test('default is not active', () {
      const filter = FavoritesActiveFilter();
      expect(filter.isActive, isFalse);
    });

    test('isActive when type is set', () {
      const filter = FavoritesActiveFilter(type: 'tv');
      expect(filter.isActive, isTrue);
    });

    test('isActive when orderBy is not default', () {
      const filter = FavoritesActiveFilter(orderBy: 'score');
      expect(filter.isActive, isTrue);
    });

    test('default orderBy is date_added', () {
      const filter = FavoritesActiveFilter();
      expect(filter.orderBy, 'date_added');
    });

    test('copyWith overrides type', () {
      const original = FavoritesActiveFilter(type: 'tv');
      final copy = original.copyWith(type: () => 'movie');
      expect(copy.type, 'movie');
      expect(copy.orderBy, 'date_added');
    });

    test('copyWith sets type to null', () {
      const original = FavoritesActiveFilter(type: 'tv');
      final copy = original.copyWith(type: () => null);
      expect(copy.type, isNull);
    });

    test('copyWith overrides orderBy', () {
      const original = FavoritesActiveFilter();
      final copy = original.copyWith(orderBy: 'score');
      expect(copy.orderBy, 'score');
    });
  });
}