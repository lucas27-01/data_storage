class StringConstraints {
  StringConstraints.standard() {
    minLength = maxLength = null;
    onlyAlphabetical = false;
  }

  StringConstraints({
    this.maxLength,
    this.minLength,
    this.onlyAlphabetical = false,
  });

  factory StringConstraints.fromJson(Map<String, dynamic> json) {
    return StringConstraints(
      maxLength: json["maxLength"],
      minLength: json["minLength"],
      onlyAlphabetical: json["onlyAlphabetical"],
    );
  }

  late int? minLength;
  late int? maxLength;
  late bool onlyAlphabetical; // The field can contains only letter if true

  Map<String, dynamic> toJson() {
    return {
      "maxLength": maxLength,
      "minLength": minLength,
      "onlyAlphabetical": onlyAlphabetical,
    };
  }
}
