import 'package:data_storage/models/representable_data_types/representable_integer.dart';
import 'package:data_storage/models/representable_data_types/representable_string.dart';
import 'package:flutter/material.dart';

abstract class RepresentableDataType {
  RepresentableDataType.standard();

  factory RepresentableDataType.fromJson(Map<String, dynamic> json) {
    switch (json["_type"]) {
      case "RepresentableInteger":
        return RepresentableInteger.fromJson(json);
      default:
        throw Exception("Unknown type ${json["_type"]}");
    }
  }

  static final representableDataTypes = {
    RepresentableInteger.standard(): "integer",
    RepresentableString.standard(): "string",
  };

  static final representableDataTypeAsIcon = {
    RepresentableInteger: Icons.numbers_rounded,
    RepresentableString: Icons.abc_rounded,
  };

  get constraints => throw Exception("This should not be seen");

  get defaultValue => throw Exception("This should not be seen");

  Widget getCreatorWidget() {
    return const Text(
        "You should not see this... This is an error, warn the developer!");
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
