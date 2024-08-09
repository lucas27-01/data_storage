import 'package:flutter/material.dart';

class UserSettings {
  UserSettings({required Locale? locale}) {
    _locale = locale;
  }

  UserSettings.standard() {
    _locale = const Locale('en');
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(locale: Locale(json['locale']));
  }

  late Locale? _locale;

  static final Map<Locale, String> languagePerLocale = {
    const Locale('en'): "English",
    const Locale('it'): "Italiano",
  };

  Locale? get locale => _locale;

  void setLocale({required Locale? locale}) {
    _locale = locale;
  }

  Map<String, dynamic> toJson() {
    return {
      "locale": _locale?.languageCode,
    };
  }
}
