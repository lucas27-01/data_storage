import 'package:flutter/material.dart';

class ThemeSettings {
  ThemeSettings.standard() {
    _brightnessTheme = Brightness.dark;
    _colorTheme = Colors.indigo;
  }

  ThemeSettings({required Brightness brightness, required Color color}) {
    _brightnessTheme = brightness;
    _colorTheme = color;
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
        brightness:
            Brightness.values.firstWhere((e) => e.name == json["brightness"]),
        color: colorNames.entries
            .firstWhere((entry) => entry.value == json["color"])
            .key);
  }

  static final Map<Color, String> colorNames = {
    Colors.amber: 'Amber',
    Colors.blue: 'Blue',
    Colors.red: 'Red',
    Colors.cyan: 'Cyan',
    Colors.green: 'Green',
    Colors.yellow: 'Yellow',
    Colors.orange: 'Orange',
    Colors.blueGrey: 'Blue Grey',
    Colors.deepPurple: 'Purple',
    Colors.indigo: 'Indigo',
    Colors.lime: 'Lime',
    Colors.pink: 'Pink',
    Colors.teal: 'Teal',
  };

  late Brightness _brightnessTheme;
  late Color _colorTheme;

  Brightness get brightnessTheme => _brightnessTheme;
  Color get colorTheme => _colorTheme;
  String? get colorThemeName => colorNames[_colorTheme];

  void enableDarkTheme() => _brightnessTheme = Brightness.dark;

  void disableDarkTheme() => _brightnessTheme = Brightness.light;

  void reverseBrightnessTheme() => _brightnessTheme =
      _brightnessTheme == Brightness.dark ? Brightness.light : Brightness.dark;

  void setColorTheme({required Color color}) => _colorTheme = color;

  Map<String, dynamic> toJson() {
    return {
      "brightness": _brightnessTheme.name,
      "color": colorNames[_colorTheme],
    };
  }
}
