import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/models/schedule_model.dart';
import '../helpers/test_data.dart';

void main() {
  group('BroadcastDay', () {
    test('apiValue matches day name lowercase', () {
      expect(BroadcastDay.monday.apiValue, 'monday');
      expect(BroadcastDay.saturday.apiValue, 'saturday');
    });

    test('label returns short name', () {
      expect(BroadcastDay.monday.label, 'Mon');
      expect(BroadcastDay.friday.label, 'Fri');
      expect(BroadcastDay.sunday.label, 'Sun');
    });

    test('fullName returns full day name', () {
      expect(BroadcastDay.wednesday.fullName, 'Wednesday');
      expect(BroadcastDay.saturday.fullName, 'Saturday');
    });

    test('all days have unique labels', () {
      final labels = BroadcastDay.values.map((d) => d.label).toList();
      expect(labels.toSet().length, BroadcastDay.values.length);
    });

    test('all days have unique apiValues', () {
      final values = BroadcastDay.values.map((d) => d.apiValue).toList();
      expect(values.toSet().length, BroadcastDay.values.length);
    });
  });

  group('ScheduleEntry.fromJson', () {
    test('parses anime correctly', () {
      final entry = ScheduleEntry.fromJson(TestData.scheduleEntryJson);

      expect(entry.anime.malId, 20);
      expect(entry.anime.title, 'Naruto');
    });

    test('parses broadcast time correctly', () {
      final entry = ScheduleEntry.fromJson(TestData.scheduleEntryJson);

      expect(entry.broadcastTime, '19:30');
      expect(entry.broadcastString, 'Saturdays at 19:30 (JST)');
    });

    test('timeOfDay parses HH:MM correctly', () {
      final entry = ScheduleEntry.fromJson(TestData.scheduleEntryJson);
      final tod = entry.timeOfDay;

      expect(tod, isNotNull);
      expect(tod!.hour, 19);
      expect(tod.minute, 30);
    });

    test('formattedTime formats PM time correctly', () {
      final entry = ScheduleEntry.fromJson(TestData.scheduleEntryJson);
      expect(entry.formattedTime, '7:30 PM');
    });

    test('formattedTime returns TBA when no broadcast time', () {
      final json = Map<String, dynamic>.from(TestData.scheduleEntryJson);
      json.remove('broadcast');
      final entry = ScheduleEntry.fromJson(json);
      expect(entry.formattedTime, 'TBA');
    });

    test('timeOfDay returns null for invalid format', () {
      final json = Map<String, dynamic>.from(TestData.scheduleEntryJson);
      json['broadcast'] = {'time': 'invalid'};
      final entry = ScheduleEntry.fromJson(json);
      expect(entry.timeOfDay, isNull);
    });
  });
}