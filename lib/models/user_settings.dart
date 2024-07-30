class UserSettings {
  UserSettings({required Locales locale}) {
    _locale = locale;
  }

  UserSettings.standard() {
    _locale = Locales.GB_en;
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
        locale: Locales.values.firstWhere((e) => e.name == json["locale"]));
  }

  late Locales _locale;

  static final Map<Locales, String> languagePerLocale = {
    Locales.GB_en: "English (UK)",
    Locales.IT_it: "Italiano (Italia)",
  };

  Locales get locale => _locale;

  void setLocale({required Locales locale}) {
    _locale = locale;
  }

  Map<String, dynamic> toJson() {
    return {
      "locale": _locale.name,
    };
  }
}

// ignore: constant_identifier_names
enum Locales { GB_en, IT_it }
