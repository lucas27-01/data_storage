class DecimalConstraints {
  DecimalConstraints.standard() {
    minValue = maxValue = multipleOf = minDecimalPlaces = maxDecimalPlaces = null;
  }

  DecimalConstraints({
    this.maxValue,
    this.minValue,
    this.maxDecimalPlaces,
    this.minDecimalPlaces,
    this.multipleOf,
  });

  factory DecimalConstraints.fromJson(Map<String, dynamic> json) {
    return DecimalConstraints(
        maxValue: json["maxValue"],
        minValue: json["minValue"],
        minDecimalPlaces: json["minDecimalPlaces"],
        maxDecimalPlaces: json["maxDecimalPlaces"],
        multipleOf: json["multipleOf"]);
  }

  late double? minValue;
  late double? maxValue;
  late double? multipleOf;
  late int? minDecimalPlaces;
  late int? maxDecimalPlaces;

  Map<String, dynamic> toJson() {
    return {
      "maxValue": maxValue,
      "minValue": minValue,
      "minDecimalPlaces": minDecimalPlaces,
      "maxDecimalPlaces": maxDecimalPlaces,
      "multipleOf": multipleOf
    };
  }
}
