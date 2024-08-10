class DecimalConstraints {
  DecimalConstraints.standard() {
    minValue = maxValue = multipleOf = null;
  }

  DecimalConstraints({
    this.maxValue,
    this.minValue,
    this.multipleOf,
  });

  factory DecimalConstraints.fromJson(Map<String, dynamic> json) {
    return DecimalConstraints(
        maxValue: json["maxValue"],
        minValue: json["minValue"],
        multipleOf: json["multipleOf"]);
  }

  late num? minValue;
  late num? maxValue;
  late num? multipleOf;

  Map<String, dynamic> toJson() {
    return {
      "maxValue": maxValue,
      "minValue": minValue,
      "multipleOf": multipleOf
    };
  }
}
