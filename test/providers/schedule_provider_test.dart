import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/providers/schedule_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';
import 'package:anime_discovery/models/schedule_model.dart';
import '../helpers/mock_api_service.dart';

void main() {
  late ScheduleProvider provider;
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
    provider = ScheduleProvider(apiService: mockApi);
  });

  tearDown(() {
    provider.dispose();
    mockApi.reset();
  });

  group('selectDay', () {
    test('starts on today or monday', () {
      expect(provider.selectedDay, isA<BroadcastDay>());
    });

    test('selectDay changes selected day', () {
      provider.selectDay(BroadcastDay.friday);
      expect(provider.selectedDay, BroadcastDay.friday);
    });

    test('selectDay triggers fetch when day not yet loaded', () async {
      provider.selectDay(BroadcastDay.wednesday);
      await Future.delayed(Duration.zero);
      expect(mockApi.getScheduleCallCount, greaterThan(0));
    });

    test('selectDay does nothing when same day selected', () {
      final day = provider.selectedDay;
      provider.selectDay(day);
      // No fetch triggered for same day.
      expect(mockApi.getScheduleCallCount, 0);
    });
  });

  group('fetchSchedule', () {
    test('starts in initial state for each day', () {
      for (final day in BroadcastDay.values) {
        expect(provider.stateFor(day), FetchState.initial);
        expect(provider.entriesFor(day), isEmpty);
      }
    });

    test('sets loaded state with results', () async {
      await provider.fetchSchedule(BroadcastDay.monday);
      expect(provider.stateFor(BroadcastDay.monday), FetchState.loaded);
      expect(provider.entriesFor(BroadcastDay.monday), isNotEmpty);
    });

    test('sets error state on failure', () async {
      mockApi.shouldThrow = true;
      await provider.fetchSchedule(BroadcastDay.monday);
      expect(provider.stateFor(BroadcastDay.monday), FetchState.error);
      expect(provider.errorFor(BroadcastDay.monday), isNotEmpty);
    });

    test('loads more and appends', () async {
      await provider.fetchSchedule(BroadcastDay.monday);
      final first = provider.entriesFor(BroadcastDay.monday).length;
      await provider.fetchSchedule(BroadcastDay.monday, loadMore: true);
      expect(
        provider.entriesFor(BroadcastDay.monday).length,
        first * 2,
      );
    });

    test('does not load more when hasMore is false', () async {
      mockApi.returnEmpty = true;
      await provider.fetchSchedule(BroadcastDay.monday);
      expect(provider.hasMoreFor(BroadcastDay.monday), isFalse);
      await provider.fetchSchedule(BroadcastDay.monday, loadMore: true);
      expect(mockApi.getScheduleCallCount, 1);
    });

    test('fresh fetch resets page to 1', () async {
      await provider.fetchSchedule(BroadcastDay.monday);
      await provider.fetchSchedule(BroadcastDay.monday, loadMore: true);
      expect(provider.pageFor(BroadcastDay.monday), 2);
      await provider.fetchSchedule(BroadcastDay.monday);
      expect(provider.pageFor(BroadcastDay.monday), 1);
    });

    test('each day has independent state', () async {
      await provider.fetchSchedule(BroadcastDay.monday);
      expect(provider.stateFor(BroadcastDay.monday), FetchState.loaded);
      expect(provider.stateFor(BroadcastDay.tuesday), FetchState.initial);
    });
  });

  group('refreshDay', () {
    test('re-fetches and replaces entries', () async {
      await provider.fetchSchedule(BroadcastDay.monday);
      final first = provider.entriesFor(BroadcastDay.monday).length;
      await provider.refreshDay(BroadcastDay.monday);
      expect(provider.entriesFor(BroadcastDay.monday).length, first);
      expect(mockApi.getScheduleCallCount, 2);
    });
  });
}