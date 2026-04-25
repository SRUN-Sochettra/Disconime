import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_discovery/services/cache_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  final cache = CacheService.instance;

  group('CacheService.set / get', () {
    test('stores and retrieves a value within TTL', () async {
      await cache.set('test_key', {'value': 42});

      final result = await cache.get(
        'test_key',
        ttl: const Duration(minutes: 10),
      );

      expect(result, isNotNull);
      expect(result['value'], 42);
    });

    test('returns null for missing key', () async {
      final result = await cache.get(
        'nonexistent',
        ttl: const Duration(minutes: 10),
      );
      expect(result, isNull);
    });

    test('returns null for expired entry', () async {
      await cache.set('expired_key', {'value': 'old'});

      // TTL of zero means always expired.
      final result = await cache.get(
        'expired_key',
        ttl: Duration.zero,
      );
      expect(result, isNull);
    });

    test('stores complex nested data', () async {
      final data = {
        'data': [
          {'mal_id': 1, 'title': 'Test'},
          {'mal_id': 2, 'title': 'Test2'},
        ],
        'pagination': {'current_page': 1},
      };

      await cache.set('complex_key', data);

      final result = await cache.get(
        'complex_key',
        ttl: const Duration(minutes: 10),
      );

      expect(result, isNotNull);
      expect((result['data'] as List).length, 2);
      expect(result['pagination']['current_page'], 1);
    });

    test('overwrites existing key', () async {
      await cache.set('overwrite_key', {'value': 1});
      await cache.set('overwrite_key', {'value': 2});

      final result = await cache.get(
        'overwrite_key',
        ttl: const Duration(minutes: 10),
      );
      expect(result['value'], 2);
    });
  });

  group('CacheService.invalidate', () {
    test('removes specific key', () async {
      await cache.set('remove_key', {'value': 'data'});
      await cache.invalidate('remove_key');

      final result = await cache.get(
        'remove_key',
        ttl: const Duration(minutes: 10),
      );
      expect(result, isNull);
    });

    test('does not affect other keys', () async {
      await cache.set('key_a', {'value': 'a'});
      await cache.set('key_b', {'value': 'b'});

      await cache.invalidate('key_a');

      final resultB = await cache.get(
        'key_b',
        ttl: const Duration(minutes: 10),
      );
      expect(resultB, isNotNull);
    });
  });

  group('CacheService.clearAll', () {
    test('removes all cache entries', () async {
      await cache.set('key1', {'v': 1});
      await cache.set('key2', {'v': 2});
      await cache.set('key3', {'v': 3});

      await cache.clearAll();

      for (final key in ['key1', 'key2', 'key3']) {
        final result = await cache.get(
          key,
          ttl: const Duration(minutes: 10),
        );
        expect(result, isNull, reason: '$key should be cleared');
      }
    });
  });

  group('CacheService key builders', () {
    test('topAnimeKey includes all params', () {
      final key = CacheService.topAnimeKey(
        page: 2,
        type: 'tv',
        filter: 'airing',
      );
      expect(key, contains('2'));
      expect(key, contains('tv'));
      expect(key, contains('airing'));
    });

    test('searchKey includes query and page', () {
      final key = CacheService.searchKey('naruto', 3);
      expect(key, contains('naruto'));
      expect(key, contains('3'));
    });

    test('detailKey includes malId', () {
      final key = CacheService.detailKey(5114);
      expect(key, contains('5114'));
    });

    test('scheduleKey includes day and page', () {
      final key = CacheService.scheduleKey('monday', 1);
      expect(key, contains('monday'));
      expect(key, contains('1'));
    });

    test('different keys do not collide', () {
      final k1 = CacheService.detailKey(1);
      final k2 = CacheService.detailKey(2);
      final k3 = CacheService.topCharactersKey(1);

      expect(k1, isNot(equals(k2)));
      expect(k1, isNot(equals(k3)));
    });
  });
}