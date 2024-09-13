class StringConstraints {
  StringConstraints.standard() {
    minLength = maxLength = null;
    onlyAlphabetical = false;
    isRequired = true;
  }

  StringConstraints({
    this.isRequired = true,
    this.maxLength,
    this.minLength,
    this.onlyAlphabetical = false,
  });

  factory StringConstraints.fromJson(Map<String, dynamic> json) {
    return StringConstraints(
      isRequired: json["isRequired"] ?? true,
      maxLength: json["maxLength"],
      minLength: json["minLength"],
      onlyAlphabetical: json["onlyAlphabetical"],
    );
  }

  late int? minLength;
  late int? maxLength;
  late bool onlyAlphabetical; // The field can contains only letter if true
  late bool isRequired;

  Map<String, dynamic> toJson() {
    return {
      "isRequired": isRequired,
      "maxLength": maxLength,
      "minLength": minLength,
      "onlyAlphabetical": onlyAlphabetical,
    };
  }
}
