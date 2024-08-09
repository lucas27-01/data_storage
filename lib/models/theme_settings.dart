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
    Colors.amber: 'amber',
    Colors.blue: 'blue',
    Colors.red: 'red',
    Colors.cyan: 'cyan',
    Colors.green: 'green',
    Colors.yellow: 'yellow',
    Colors.orange: 'orange',
    Colors.blueGrey: 'blueGrey',
    Colors.deepPurple: 'purple',
    Colors.indigo: 'indigo',
    Colors.lime: 'lime',
    Colors.pink: 'pink',
    Colors.teal: 'teal',
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
