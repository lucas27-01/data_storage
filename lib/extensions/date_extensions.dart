import 'package:data_storage/models/user_settings.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

extension DateTimeExtensions on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

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
}
