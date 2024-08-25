import 'package:flutter/material.dart';

class UserSettings {
  UserSettings(
      {required Locale? locale, Locale? dateFormat, this.use24H = true}) {
    _locale = locale;
    _dateFormat = dateFormat ?? locale;
  }

  UserSettings.standard() {
    _locale = _dateFormat = const Locale('en');
    use24H = true;
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      locale: Locale(json['locale']),
      dateFormat: Locale(json['dateFormat']),
      use24H: json['use24H'],
    );
  }

  late Locale? _locale;
  late Locale? _dateFormat;
  bool use24H = true; // Use 24 Hour format (no AM/PM)

  static final Map<Locale, String> languagePerLocale = {
    const Locale('en'): "English",
    const Locale('it'): "Italiano",
  };

  static final Map<Locale, String> dateFormatPerLocale = {
    const Locale('en'): "MM/dd/yyyy",
    const Locale('it'): "dd/MM/yyyy",
  };

  Locale? get locale => _locale;
  Locale? get dateFormat => _dateFormat;

  void setLocale({required Locale? locale}) {
    _locale = locale;
  }

  void setDateFormat({required Locale? localeFormat}) {
    _dateFormat = localeFormat;
  }

  Map<String, dynamic> toJson() {
    return {
      "locale": _locale?.languageCode,
      "dateFormat": _dateFormat?.languageCode,
      "use24H": use24H,
    };
  }
}
