import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_discovery/providers/theme_provider.dart';

void main() {
  late ThemeProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    provider = ThemeProvider();
    await provider.loadTheme();
  });

  tearDown(() {
    provider.dispose();
  });

  group('loadTheme', () {
    test('defaults to dark mode', () {
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);
    });

    test('loads persisted dark theme', () async {
      await provider.toggleTheme(true);

      final newProvider = ThemeProvider();
      await newProvider.loadTheme();

      expect(newProvider.isDarkMode, isTrue);
      newProvider.dispose();
    });

    test('loads persisted light theme', () async {
      await provider.toggleTheme(false);

      final newProvider = ThemeProvider();
      await newProvider.loadTheme();

      expect(newProvider.isDarkMode, isFalse);
      newProvider.dispose();
    });
  });

  group('toggleTheme', () {
    test('switches to light mode', () async {
      await provider.toggleTheme(false);

      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, isFalse);
    });

    test('switches to dark mode', () async {
      await provider.toggleTheme(false);
      await provider.toggleTheme(true);

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);
    });

    test('persists to SharedPreferences', () async {
      await provider.toggleTheme(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('theme_is_dark'), isFalse);
    });

    test('notifies listeners on change', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.toggleTheme(false);

      expect(notified, isTrue);
    });
  });
}