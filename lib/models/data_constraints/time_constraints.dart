import 'package:data_storage/extensions/date_extensions.dart';
import 'package:flutter/material.dart';

class TimeConstraints {
  TimeConstraints.standard() {
    minValue = maxValue = hasToBeFuture = null;
    isRequired = true;
  }

  TimeConstraints({
    this.isRequired = true,
    this.maxValue,
    this.minValue,
    this.hasToBeFuture,
  });

  factory TimeConstraints.fromJson(Map<String, dynamic> json) {
    return TimeConstraints(
      isRequired: json["isRequired"] ?? true,
      maxValue: TimeOfDayExtension.fromNullableJson(json['maxValue']),
      minValue: TimeOfDayExtension.fromNullableJson(json['minValue']),
      hasToBeFuture: json['hasToBeFuture'],
    );
  }

  late TimeOfDay? minValue;
  late TimeOfDay? maxValue;
  late bool isRequired;

  /// When true the value has to be in the future, if false it has to be in the past, if null no constraint
  late bool? hasToBeFuture;

  Map<String, dynamic> toJson() {
    return {
      "isRequired": isRequired,
      "maxValue": maxValue?.toJson(),
      "minValue": minValue?.toJson(),
      "hasToBeFuture": hasToBeFuture,
    };
  }
}
