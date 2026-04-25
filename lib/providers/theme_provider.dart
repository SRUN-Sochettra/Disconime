import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_is_dark';

  // FIX: themeMode is now private with a getter.
  // Default is dark until loadTheme() resolves.
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // FIX: Loads the persisted theme choice from SharedPreferences.
  // Called in main() before runApp() so the correct theme is
  // applied on the very first frame with no flash.
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_key) ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      // No notifyListeners() needed here — called before runApp().
    } catch (e) {
      debugPrint('[ThemeProvider] failed to load theme: $e');
    }
  }

  // FIX: toggleTheme is now async and persists the new choice.
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, isDark);
    } catch (e) {
      debugPrint('[ThemeProvider] failed to persist theme: $e');
    }
  }
}