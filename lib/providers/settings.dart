import 'dart:convert';

import 'package:data_storage/models/user_settings.dart';
import 'package:data_storage/utils/file_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/theme_settings.dart';

class Settings with ChangeNotifier {
  Settings(
      {required Color colorTheme,
      required Brightness brightnessTheme,
      required Locales locale}) {
    _themeSettings =
        ThemeSettings(brightness: brightnessTheme, color: colorTheme);
    _userSettings = UserSettings(locale: locale);
  }

  Settings.viaClass(
      {required ThemeSettings themeSettings,
      required UserSettings userSettings}) {
    _themeSettings = themeSettings;
    _userSettings = userSettings;
  }

  void createFromJson(Map<String, dynamic> json){
    var newSettings = Settings.fromJson(json);
    _themeSettings = newSettings._themeSettings;
    _userSettings = newSettings._userSettings;
  }

  Settings.standard() {
    _themeSettings = ThemeSettings.standard();
    _userSettings = UserSettings.standard();
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings.viaClass(
        themeSettings: ThemeSettings.fromJson(json["theme"]),
        userSettings: UserSettings.fromJson(json["user"]));
  }

  late final ThemeSettings _themeSettings;
  late final UserSettings _userSettings;

  Brightness get brightnessTheme => _themeSettings.brightnessTheme;
  Color get colorTheme => _themeSettings.colorTheme;
  String? get colorThemeName => _themeSettings.colorThemeName;
  Locales get locale => _userSettings.locale;

  void _writeSettingsFile(){
    FileManager.saveSettings(jsonEncode(toJson()));
  }

  void enableDarkTheme() {
    _themeSettings.enableDarkTheme();
    _writeSettingsFile();
    notifyListeners();
  }

  void disableDarkTheme() {
    _themeSettings.disableDarkTheme();
    _writeSettingsFile();
    notifyListeners();
  }

  void reverseBrightnessTheme() {
    _themeSettings.reverseBrightnessTheme();
    _writeSettingsFile();
    notifyListeners();
  }

  void setColorTheme({required Color color}) {
    _themeSettings.setColorTheme(color: color);
    _writeSettingsFile();
    notifyListeners();
  }

  void setLocale({required Locales locale}) {
    _userSettings.setLocale(locale: locale);
    _writeSettingsFile();
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      "theme": _themeSettings.toJson(),
      "user": _userSettings.toJson(),
    };
  }
}