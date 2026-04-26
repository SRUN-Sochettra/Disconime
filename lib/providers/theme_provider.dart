import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_is_dark';

  ThemeMode _themeMode = ThemeMode.dark;
  SharedPreferences? _prefs; // Cached instance — matches pattern used by other providers.

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Loads the persisted theme choice from SharedPreferences.
  /// Called in main() before runApp() so the correct theme is
  /// applied on the very first frame with no flash.
  Future<void> loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final isDark = _prefs!.getBool(_key) ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      // No notifyListeners() needed here — called before runApp().
    } catch (e) {
      debugPrint('[ThemeProvider] failed to load theme: $e');
    }
  }

  /// Toggles the theme and persists the new choice using the
  /// cached [SharedPreferences] instance for zero-overhead writes.
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      // Reuse cached prefs; fall back to getInstance() only if
      // toggleTheme is called before loadTheme() completes (e.g. in tests).
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_key, isDark);
    } catch (e) {
      debugPrint('[ThemeProvider] failed to persist theme: $e');
    }
  }
}