import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/representable_data_types/representable_boolean.dart';
import 'package:data_storage/models/representable_data_types/representable_decimal.dart';
import 'package:data_storage/models/representable_data_types/representable_integer.dart';
import 'package:data_storage/models/representable_data_types/representable_string.dart';
import 'package:data_storage/models/representable_data_types/representable_time.dart';
import 'package:flutter/material.dart';

abstract class RepresentableDataType {
  RepresentableDataType.standard();

  factory RepresentableDataType.fromJson(Map<String, dynamic> json) {
    switch (json["_type"]) {
      case "RepresentableInteger":
        return RepresentableInteger.fromJson(json);
      case "RepresentableString":
        return RepresentableString.fromJson(json);
      case "RepresentableDecimal":
        return RepresentableDecimal.fromJson(json);
      case "RepresentableBoolean":
        return RepresentableBoolean.fromJson(json);
      case "RepresentableTime":
        return RepresentableTime.fromJson(json);
      default:
        throw Exception(
            "Type Error: Unknown type ${json["_type"]} for factory RepresentableDataType.fromJson");
    }
  }

  static final representableDataTypes = {
    RepresentableInteger.standard(): "integer",
    RepresentableString.standard(): "string",
    RepresentableDecimal.standard(): "decimal",
    RepresentableBoolean.standard(): "boolean",
    RepresentableTime.standard(): "time_",
  };

  static final representableDataTypeAsIcon = {
    RepresentableInteger: Icons.numbers_rounded,
    RepresentableString: Icons.abc_rounded,
    RepresentableDecimal: Icons.calculate_rounded,
    RepresentableBoolean: Icons.check_rounded,
    RepresentableTime: Icons.access_time_rounded,
  };

  get constraints =>
      throw Exception("RepresentableDataType called an invalid getter");

  get defaultValue =>
      throw Exception("RepresentableDataType called an invalid getter");

  get customDefaultValue =>
      throw Exception("RepresentableDataType called an invalid getter");

  get statsToSee =>
      throw Exception("RepresentableDataType called an invalid getter");

  Map<String, dynamic> get values =>
      throw Exception("RepresentableDataType called an invalid getter");

  Map<String, dynamic> toJson() {
    return {};
  }

  Widget builderWidget({Data? dataToEdit}) {
    throw Exception("RepresentableDataType called an invalid method");
  }

  Type get wantedType =>
      throw Exception("RepresentableDataType called an invalid getter");

  String getStat({required BuildContext context, required dynamic stat}) =>
      throw Exception("RepresentableDataType called an invalid method");
}
