import 'package:data_storage/models/user_settings.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

extension DateTimeExtensions on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  DateTime onlyDate() {
    return DateTime(year, month, day);
  }

  static DateTime calculateMean(List<DateTime> dates) {
    if (dates.isEmpty) return DateTime(0);

    int totalMinutes = dates
        .map((date) => date.secondsSinceEpoch)
        .toList()
        .reduce((a, b) => a + b);

    return DateTimeExtensions.fromSecondsSinceEpoch(
        totalMinutes ~/ dates.length);
  }

  static DateTime fromSecondsSinceEpoch(int secondsSinceEpoch,
      {bool isUtc = false}) {
    return DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000,
        isUtc: isUtc);
  }

  String formatDateTimeLocalized(BuildContext context) {
    // Create a formatter for DateTime
    final DateFormat formatter = DateFormat(
        "${UserSettings.dateFormatPerLocale[context.read<Settings>().dateFormat]} ${context.read<Settings>().use24H ? "HH:mm" : "hh:mm a"}");

    // Combina data e ora
    return formatter.format(this);
  }

  String formatOnlyDate(BuildContext context) {
    return DateFormat(UserSettings
            .dateFormatPerLocale[context.read<Settings>().dateFormat])
        .format(this);
  }

// I don't used operator because the compartion is only between date
  bool isDateGreater(DateTime other) {
    if (year > other.year) return true;
    if (year < other.year) return false;
    if (month > other.month) return true;
    if (month < other.month) return false;
    return day > other.day;
  }

  bool isDateSmaller(DateTime other) {
    if (year < other.year) return true;
    if (year > other.year) return false;
    if (month < other.month) return true;
    if (month > other.month) return false;
    return day < other.day;
  }

  Map<String, dynamic> onlyDateToJson() {
    return {
      "day": day,
      "month": month,
      "year": year,
    };
  }

  static DateTime onlyDatefromJson(Map<String, dynamic> json) {
    return DateTime(
      json['year'],
      json['month'],
      json['day'],
    );
  }

  static DateTime? onlyDatefromNullableJson(Map<String, dynamic>? json) {
    try {
      return DateTime(
        json!['year'],
        json['month'],
        json['day'],
      );
    } catch (_) {
      return null;
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  Map<String, dynamic> toJson() {
    return {'minute': minute, 'hour': hour};
  }

  static TimeOfDay fromJson(Map<String, dynamic> json) {
    return TimeOfDay(hour: json['hour'], minute: json['minute']);
  }

  static TimeOfDay? fromNullableJson(Map<String, dynamic>? json) {
    try {
      return TimeOfDay(hour: json?['hour'], minute: json?['minute']);
    } catch (_) {
      return null;
    }
  }

  static TimeOfDay calulateMean(List<TimeOfDay> times) {
    if (times.isEmpty) return const TimeOfDay(hour: 0, minute: 0);

    int totalMinutes = times
        .map((time) => time.minute + time.hour * 60)
        .toList()
        .reduce((a, b) => a + b);

    int averageMinutes = totalMinutes ~/ times.length;

    return TimeOfDay(hour: averageMinutes ~/ 60, minute: averageMinutes % 60);
  }

  int toMinute() {
    return minute + hour * 60;
  }

  bool operator <(TimeOfDay other) {
    if (hour < other.hour) return true;
    if (hour > other.hour) return false;
    return minute < other.minute;
  }

  bool operator >(TimeOfDay other) {
    if (hour > other.hour) return true;
    if (hour < other.hour) return false;
    return minute > other.minute;
  }

  bool operator <=(TimeOfDay other) {
    return this < other || this == other;
  }

  bool operator >=(TimeOfDay other) {
    return this > other || this == other;
  }
}
