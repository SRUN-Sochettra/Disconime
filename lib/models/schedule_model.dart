import 'anime_model.dart';

/// The seven broadcast days returned by the Jikan schedule endpoint.
enum BroadcastDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension BroadcastDayExtension on BroadcastDay {
  /// API query string value.
  String get apiValue => name.toLowerCase();

  /// Display label shown in the tab bar.
  String get label {
    switch (this) {
      case BroadcastDay.monday:
        return 'Mon';
      case BroadcastDay.tuesday:
        return 'Tue';
      case BroadcastDay.wednesday:
        return 'Wed';
      case BroadcastDay.thursday:
        return 'Thu';
      case BroadcastDay.friday:
        return 'Fri';
      case BroadcastDay.saturday:
        return 'Sat';
      case BroadcastDay.sunday:
        return 'Sun';
    }
  }

  /// Full day name for section headers.
  String get fullName {
    switch (this) {
      case BroadcastDay.monday:
        return 'Monday';
      case BroadcastDay.tuesday:
        return 'Tuesday';
      case BroadcastDay.wednesday:
        return 'Wednesday';
      case BroadcastDay.thursday:
        return 'Thursday';
      case BroadcastDay.friday:
        return 'Friday';
      case BroadcastDay.saturday:
        return 'Saturday';
      case BroadcastDay.sunday:
        return 'Sunday';
    }
  }

  /// Whether this day is today.
  bool get isToday {
    // DateTime.weekday: 1=Monday … 7=Sunday
    final todayIndex = DateTime.now().weekday - 1;
    return index == todayIndex;
  }
}

/// A scheduled anime entry — extends [Anime] with broadcast time.
class ScheduleEntry {
  final Anime anime;
  final String? broadcastTime;
  final String? broadcastString;

  const ScheduleEntry({
    required this.anime,
    this.broadcastTime,
    this.broadcastString,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    final broadcast = json['broadcast'] as Map<String, dynamic>?;

    return ScheduleEntry(
      anime: Anime.fromJson(json),
      broadcastTime: broadcast?['time'] as String?,
      broadcastString: broadcast?['string'] as String?,
    );
  }

  /// Parsed [TimeOfDay] from the broadcast time string (e.g. "23:30").
  TimeOfDay? get timeOfDay {
    if (broadcastTime == null) return null;
    final parts = broadcastTime!.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Formatted time string for display (e.g. "11:30 PM").
  String get formattedTime {
    final tod = timeOfDay;
    if (tod == null) return 'TBA';
    final hour = tod.hour % 12 == 0 ? 12 : tod.hour % 12;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}