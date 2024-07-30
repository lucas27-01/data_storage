import 'package:flutter/material.dart';

class ThemeSettings {
  ThemeSettings();

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

  Brightness _brightnessTheme = Brightness.dark;
  Color _colorTheme = Colors.indigo;

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
