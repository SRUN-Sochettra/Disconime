import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_discovery/providers/search_history_provider.dart';

void main() {
  late SearchHistoryProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    provider = SearchHistoryProvider();
    await provider.loadHistory();
  });

  tearDown(() {
    provider.dispose();
  });

  group('loadHistory', () {
    test('starts empty', () {
      expect(provider.history, isEmpty);
    });

    test('loads persisted history', () async {
      await provider.addQuery('naruto');
      await provider.addQuery('one piece');

      final newProvider = SearchHistoryProvider();
      await newProvider.loadHistory();

      expect(newProvider.history.length, 2);
      newProvider.dispose();
    });
  });

  group('addQuery', () {
    test('adds query to top of history', () async {
      await provider.addQuery('naruto');
      await provider.addQuery('one piece');

      expect(provider.history.first, 'one piece');
      expect(provider.history[1], 'naruto');
    });

    test('deduplicates — moves existing query to top', () async {
      await provider.addQuery('naruto');
      await provider.addQuery('one piece');
      await provider.addQuery('naruto');

      expect(provider.history.length, 2);
      expect(provider.history.first, 'naruto');
    });

    test('ignores empty queries', () async {
      await provider.addQuery('');
      await provider.addQuery('   ');

      expect(provider.history, isEmpty);
    });

    test('trims whitespace from queries', () async {
      await provider.addQuery('  naruto  ');

      expect(provider.history.first, 'naruto');
    });

    test('caps history at 15 entries', () async {
      for (var i = 0; i < 20; i++) {
        await provider.addQuery('query$i');
      }

      expect(provider.history.length, 15);
    });

    test('persists to SharedPreferences', () async {
      await provider.addQuery('naruto');

      final newProvider = SearchHistoryProvider();
      await newProvider.loadHistory();

      expect(newProvider.history.contains('naruto'), isTrue);
      newProvider.dispose();
    });
  });

  group('removeQuery', () {
    test('removes specific query', () async {
      await provider.addQuery('naruto');
      await provider.addQuery('one piece');

      await provider.removeQuery('naruto');

      expect(provider.history.contains('naruto'), isFalse);
      expect(provider.history.contains('one piece'), isTrue);
    });

    test('does nothing for non-existent query', () async {
      await provider.addQuery('naruto');
      await provider.removeQuery('bleach');

      expect(provider.history.length, 1);
    });

    test('persists removal', () async {
      await provider.addQuery('naruto');
      await provider.removeQuery('naruto');

      final newProvider = SearchHistoryProvider();
      await newProvider.loadHistory();

      expect(newProvider.history, isEmpty);
      newProvider.dispose();
    });
  });

  group('clearHistory', () {
    test('clears all entries', () async {
      await provider.addQuery('naruto');
      await provider.addQuery('one piece');
      await provider.addQuery('bleach');

      await provider.clearHistory();

      expect(provider.history, isEmpty);
    });

    test('persists clear to SharedPreferences', () async {
      await provider.addQuery('naruto');
      await provider.clearHistory();

      final newProvider = SearchHistoryProvider();
      await newProvider.loadHistory();

      expect(newProvider.history, isEmpty);
      newProvider.dispose();
    });
  });
}