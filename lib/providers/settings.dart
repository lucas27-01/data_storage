import 'package:data_storage/models/user_settings.dart';
import 'package:flutter/material.dart';
import '../models/theme_settings.dart';

class Settings with ChangeNotifier {
  final ThemeSettings _themeSettings = ThemeSettings();
  final UserSettings _userSettings = UserSettings();

  Brightness get brightnessTheme => _themeSettings.brightnessTheme;
  Color get colorTheme => _themeSettings.colorTheme;
  String? get colorThemeName => _themeSettings.colorThemeName;
  Locales get locale => _userSettings.locale;

  //void _writeSettingsFile(){
  //  FileManager.saveSettings()
  //}

  void enableDarkTheme() {
    _themeSettings.enableDarkTheme();
    notifyListeners();
  }

  void disableDarkTheme() {
    _themeSettings.disableDarkTheme();
    notifyListeners();
  }

  void reverseBrightnessTheme() {
    _themeSettings.reverseBrightnessTheme();
    notifyListeners();
  }

  void setColorTheme({required Color color}) {
    _themeSettings.setColorTheme(color: color);
    notifyListeners();
  }

  void setLocale({required Locales locale}) {
    _userSettings.setLocale(locale: locale);
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      "theme": _themeSettings.toJson(),
      "user": _userSettings.toJson(),
    };
  }
}
