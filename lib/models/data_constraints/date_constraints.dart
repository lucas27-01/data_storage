import 'package:data_storage/extensions/date_extensions.dart';

class DateConstraints {
  DateConstraints.standard() {
    minValue = maxValue = hasToBeFuture = null;
    isRequired = true;
  }

  DateConstraints({
    this.isRequired = true,
    this.maxValue,
    this.minValue,
    this.hasToBeFuture,
  });

  factory DateConstraints.fromJson(Map<String, dynamic> json) {
    return DateConstraints(
      isRequired: json["isRequired"] ?? true,
      maxValue: DateTimeExtensions.onlyDatefromNullableJson(json['maxValue']),
      minValue: DateTimeExtensions.onlyDatefromNullableJson(json['minValue']),
      hasToBeFuture: json['hasToBeFuture'],
    );
  }

  late DateTime? minValue;
  late DateTime? maxValue;
  late bool isRequired;

  /// When true the value has to be in the future, if false it has to be in the past, if null no constraint
  late bool? hasToBeFuture;

  Map<String, dynamic> toJson() {
    return {
      "isRequired": isRequired,
      "maxValue": maxValue?.onlyDateToJson(),
      "minValue": minValue?.onlyDateToJson(),
      "hasToBeFuture": hasToBeFuture,
    };
  }
}
