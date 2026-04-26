import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';
import '../services/api_service.dart';
import '../utils/error_utils.dart';

enum FetchState { initial, loading, loaded, error }

class ScheduleProvider extends ChangeNotifier {
  final ApiService _apiService;

  ScheduleProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ── Per-day state ─────────────────────────────────────────────
  // We cache each day independently so switching tabs is instant
  // after the first load — no re-fetch needed.
  final Map<BroadcastDay, List<ScheduleEntry>> _schedules = {};
  final Map<BroadcastDay, FetchState> _states = {};
  final Map<BroadcastDay, String> _errors = {};
  final Map<BroadcastDay, int> _pages = {};
  final Map<BroadcastDay, bool> _hasMore = {};

  // ── Selected day ──────────────────────────────────────────────
  // Defaults to today so the schedule opens on the current day.
  BroadcastDay _selectedDay = _todayOrMonday();

  BroadcastDay get selectedDay => _selectedDay;

  // ── Getters ───────────────────────────────────────────────────
  List<ScheduleEntry> entriesFor(BroadcastDay day) =>
      _schedules[day] ?? [];

  FetchState stateFor(BroadcastDay day) =>
      _states[day] ?? FetchState.initial;

  String errorFor(BroadcastDay day) => _errors[day] ?? '';

  int pageFor(BroadcastDay day) => _pages[day] ?? 1;

  bool hasMoreFor(BroadcastDay day) => _hasMore[day] ?? true;

  // ── Select day ────────────────────────────────────────────────
  void selectDay(BroadcastDay day) {
    if (_selectedDay == day) return;
    _selectedDay = day;
    notifyListeners();
    // Fetch if not already loaded.
    if (stateFor(day) == FetchState.initial) {
      fetchSchedule(day);
    }
  }

  // ── Fetch ─────────────────────────────────────────────────────
  Future<void> fetchSchedule(
    BroadcastDay day, {
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!(_hasMore[day] ?? true)) return;
      if (_states[day] == FetchState.loading) return;
      _states[day] = FetchState.loading;
      _errors[day] = '';
      Future.microtask(() => notifyListeners());
    } else {
      _schedules[day] = [];
      _pages[day] = 1;
      _hasMore[day] = true;
      _states[day] = FetchState.loading;
      _errors[day] = '';
      Future.microtask(() => notifyListeners());
    }

    final currentPage = _pages[day] ?? 1;
    final pageToFetch = loadMore ? currentPage + 1 : 1;

    try {
      final results = await _apiService.getSchedule(
        day,
        page: pageToFetch,
      );

      // Guard: discard if the user switched to a different day while awaiting.
      if (day != _selectedDay) return;

      if (results.isEmpty) {
        _hasMore[day] = false;
      }

      final existing = _schedules[day] ?? [];
      _schedules[day] =
          loadMore ? [...existing, ...results] : results;
      _pages[day] = pageToFetch;
      _states[day] = FetchState.loaded;
      _errors[day] = '';
    } catch (e) {
      // Guard: don't overwrite a newer fetch's error state.
      if (day != _selectedDay) return;
      _states[day] = FetchState.error;
      _errors[day] = friendlyError(e);
    }
    notifyListeners();
  }

  /// Refreshes all already-loaded days — useful for pull-to-refresh
  /// on the currently visible tab.
  Future<void> refreshDay(BroadcastDay day) async {
    await fetchSchedule(day);
  }

  // ── Helpers ───────────────────────────────────────────────────
  static BroadcastDay _todayOrMonday() {
    // DateTime.weekday: 1=Monday … 7=Sunday
    final index = DateTime.now().weekday - 1;
    return BroadcastDay.values[index.clamp(0, 6)];
  }

}