import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
String formatDateTimeLocalized(BuildContext context) {
  const locale = 'it'; //Localizations.localeOf(context).toString(); // TODO: add DateTime localization

  // Crea un formatter per la data
  final DateFormat dateFormatter = DateFormat.yMd(locale);
  
  // Crea un formatter per l'ora
  final DateFormat timeFormatter = DateFormat.Hm(locale);

  // Combina data e ora
  return '${dateFormatter.format(this)} ${timeFormatter.format(this)}';
}
}
