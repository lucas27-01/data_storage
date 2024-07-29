import 'package:flutter/material.dart';

class Settings with ChangeNotifier {
  Brightness _brightnessTheme = Brightness.dark;
  Color _colorTheme = Colors.indigo;

  Brightness get brightnessTheme => _brightnessTheme;

  Color get colorTheme => _colorTheme;

  void enableDarkTheme() {
    _brightnessTheme = Brightness.dark;
    notifyListeners();
  }

  void disableDarkTheme() {
    _brightnessTheme = Brightness.light;
    notifyListeners();
  }

  void reverseBrightnessTheme() {
    _brightnessTheme = _brightnessTheme == Brightness.dark ? Brightness.light : Brightness.dark;
    notifyListeners();
  }

  void setColorTheme({required Color color}){
    _colorTheme = color;
    notifyListeners();
  }
}
