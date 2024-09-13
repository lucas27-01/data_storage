class DecimalConstraints {
  DecimalConstraints.standard() {
    minValue = maxValue = multipleOf = null;
    isRequired = true;
  }

  DecimalConstraints({
    this.isRequired = true,
    this.maxValue,
    this.minValue,
    this.multipleOf,
  });

  factory DecimalConstraints.fromJson(Map<String, dynamic> json) {
    return DecimalConstraints(
      isRequired: json["isRequired"] ?? true,
      maxValue: json["maxValue"],
      minValue: json["minValue"],
      multipleOf: json["multipleOf"],
    );
  }

  late num? minValue;
  late num? maxValue;
  late num? multipleOf;
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
