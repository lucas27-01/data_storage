import 'dart:math';

extension NumExtensions on num {
  num roundToDecimalPlaces(int places) {
    num mod = pow(10.0, places);
    return ((this * mod).round().toDouble() / mod);
  }
}

extension DoubleExtension on double {
  double roundToDecimalPlaces(int places) {
    double mod = pow(10.0, places).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}