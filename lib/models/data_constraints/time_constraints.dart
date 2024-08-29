import 'package:data_storage/extensions/date_extensions.dart';
import 'package:flutter/material.dart';

class TimeConstraints {
  TimeConstraints.standard() {
    minValue = maxValue = hasToBeFuture = null;
  }

  TimeConstraints({
    this.maxValue,
    this.minValue,
    this.hasToBeFuture,
  });

  factory TimeConstraints.fromJson(Map<String, dynamic> json) {
    return TimeConstraints(
      maxValue: TimeOfDayExtension.fromNullableJson(json['maxValue']),
      minValue: TimeOfDayExtension.fromNullableJson(json['minValue']),
      hasToBeFuture: json['hasToBeFuture'],
    );
  }

  late TimeOfDay? minValue;
  late TimeOfDay? maxValue;
  late bool? hasToBeFuture;

  /// When true the value has to be in the future, if false it has to be in the past, if null no constraint

  Map<String, dynamic> toJson() {
    return {
      "maxValue": maxValue?.toJson(),
      "minValue": minValue?.toJson(),
      "hasToBeFuture": hasToBeFuture,
    };
  }
}
