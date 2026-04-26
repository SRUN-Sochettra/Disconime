import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';
import '../services/api_service.dart';
import '../utils/error_utils.dart';

enum FetchState { initial, loading, loaded, error }

class ScheduleProvider extends ChangeNotifier {
  final ApiService _apiService;

  ScheduleProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final Map<BroadcastDay, List<ScheduleEntry>> _schedules = {};
  final Map<BroadcastDay, FetchState> _states = {};
  final Map<BroadcastDay, String> _errors = {};
  final Map<BroadcastDay, int> _pages = {};
  final Map<BroadcastDay, bool> _hasMore = {};

  BroadcastDay _selectedDay = _todayOrMonday();
  BroadcastDay get selectedDay => _selectedDay;

  List<ScheduleEntry> entriesFor(BroadcastDay day) =>
      _schedules[day] ?? [];
  FetchState stateFor(BroadcastDay day) =>
      _states[day] ?? FetchState.initial;
  String errorFor(BroadcastDay day) => _errors[day] ?? '';
  int pageFor(BroadcastDay day) => _pages[day] ?? 1;
  bool hasMoreFor(BroadcastDay day) => _hasMore[day] ?? true;

  void selectDay(BroadcastDay day) {
    if (_selectedDay == day) return;
    _selectedDay = day;
    notifyListeners();
    if (stateFor(day) == FetchState.initial) {
      fetchSchedule(day);
    }
  }

  Future<void> fetchSchedule(
    BroadcastDay day, {
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!(_hasMore[day] ?? true)) return;
      if (_states[day] == FetchState.loading) return;
    } else {
      _schedules[day] = [];
      _pages[day] = 1;
      _hasMore[day] = true;
    }

    // FIX: Direct notify, no microtask
    _states[day] = FetchState.loading;
    _errors[day] = '';
    notifyListeners();

    final currentPage = _pages[day] ?? 1;
    final pageToFetch = loadMore ? currentPage + 1 : 1;

    try {
      final results = await _apiService.getSchedule(
        day,
        page: pageToFetch,
      );

      if (results.isEmpty) _hasMore[day] = false;
      final existing = _schedules[day] ?? [];
      _schedules[day] =
          loadMore ? [...existing, ...results] : results;
      _pages[day] = pageToFetch;
      _states[day] = FetchState.loaded;
      _errors[day] = '';
    } catch (e) {
      _states[day] = FetchState.error;
      _errors[day] = friendlyError(e);
    }
    notifyListeners();
  }

  Future<void> refreshDay(BroadcastDay day) async {
    await fetchSchedule(day);
  }

  static BroadcastDay _todayOrMonday() {
    final index = DateTime.now().weekday - 1;
    return BroadcastDay.values[index.clamp(0, 6)];
  }
}