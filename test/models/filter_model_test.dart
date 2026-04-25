import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/models/filter_model.dart';

void main() {
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
          sort: 'desc', // sort should NOT count
        );
        expect(filter.activeCount, 4);
      });

      test('sort is excluded from count', () {
        const filter = AnimeFilter(sort: 'asc');
        expect(filter.activeCount, 0);
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
}