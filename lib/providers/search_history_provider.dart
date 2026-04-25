import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'search_history';
  static const int _maxHistory = 15;

  List<String> _history = [];

  List<String> get history => _history;

  /// Loads history from shared_preferences on app start.
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _history = prefs.getStringList(_storageKey) ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('[SearchHistoryProvider] failed to load history: $e');
    }
  }

  /// Adds a query to the top of the history list.
  /// Deduplicates and caps at [_maxHistory] entries.
  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Remove duplicate if exists, then insert at top.
    _history.remove(trimmed);
    _history.insert(0, trimmed);

    // Cap at max entries.
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }

    notifyListeners();
    await _persist();
  }

  /// Removes a single entry from history.
  Future<void> removeQuery(String query) async {
    _history.remove(query);
    notifyListeners();
    await _persist();
  }

  /// Clears all search history.
  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _history);
    } catch (e) {
      debugPrint('[SearchHistoryProvider] failed to persist history: $e');
    }
  }
}