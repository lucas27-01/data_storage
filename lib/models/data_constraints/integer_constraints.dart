class IntegerConstraints {
  IntegerConstraints.standard() {
    minValue = maxValue = multipleOf = null;
  }

  IntegerConstraints({
    this.maxValue,
    this.minValue,
    this.multipleOf,
  });

  factory IntegerConstraints.fromJson(Map<String, dynamic> json) {
    return IntegerConstraints(
        maxValue: json["maxValue"],
        minValue: json["minValue"],
        multipleOf: json["multipleOf"]);
  }

  late int? minValue;
  late int? maxValue;
  late int? multipleOf;

  Map<String, dynamic> toJson() {
    return {
      "maxValue": maxValue,
      "minValue": minValue,
      "multipleOf": multipleOf
    };
  }
}
