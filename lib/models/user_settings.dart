class UserSettings {
  var _locale = Locales.GB_en;

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
