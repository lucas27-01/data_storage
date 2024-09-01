import 'package:data_storage/extensions/date_extensions.dart';

class DateConstraints {
  DateConstraints.standard() {
    minValue = maxValue = hasToBeFuture = null;
  }

  DateConstraints({
    this.maxValue,
    this.minValue,
    this.hasToBeFuture,
  });

  factory DateConstraints.fromJson(Map<String, dynamic> json) {
    return DateConstraints(
      maxValue: DateTimeExtensions.onlyDatefromNullableJson(json['maxValue']),
      minValue: DateTimeExtensions.onlyDatefromNullableJson(json['minValue']),
      hasToBeFuture: json['hasToBeFuture'],
    );
  }

  late DateTime? minValue;
  late DateTime? maxValue;

  /// When true the value has to be in the future, if false it has to be in the past, if null no constraint
  late bool? hasToBeFuture;

  Map<String, dynamic> toJson() {
    return {
      "maxValue": maxValue?.onlyDateToJson(),
      "minValue": minValue?.onlyDateToJson(),
      "hasToBeFuture": hasToBeFuture,
    };
  }
}
