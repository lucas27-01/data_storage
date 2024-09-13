class IntegerConstraints {
  IntegerConstraints.standard() {
    minValue = maxValue = multipleOf = null;
    isRequired = true;
  }

  IntegerConstraints({
    this.isRequired = true,
    this.maxValue,
    this.minValue,
    this.multipleOf,
  });

  factory IntegerConstraints.fromJson(Map<String, dynamic> json) {
    return IntegerConstraints(
      isRequired: json["isRequired"] ?? true,
      maxValue: json["maxValue"],
      minValue: json["minValue"],
      multipleOf: json["multipleOf"],
    );
  }

  late int? minValue;
  late int? maxValue;
  late int? multipleOf;
  late bool isRequired;

  Map<String, dynamic> toJson() {
    return {
      "isRequired": isRequired,
      "maxValue": maxValue,
      "minValue": minValue,
      "multipleOf": multipleOf
    };
  }
}
