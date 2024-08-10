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
      maxLength: json["maxLenght"],
      minLength: json["minLenght"],
      onlyAlphabetical: json["onlyAlphabetical"],
    );
  }

  late int? minLength;
  late int? maxLength;
  late bool onlyAlphabetical; // The field can contains only letter if true

  Map<String, dynamic> toJson() {
    return {
      "maxLenght": maxLength,
      "minLenght": minLength,
      "onlyAlphabetical": onlyAlphabetical,
    };
  }
}
