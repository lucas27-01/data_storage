import 'package:data_storage/extensions/num_extensions.dart';
import 'package:data_storage/models/representable_data_types/representable_boolean.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:data_storage/models/representable_data_types/representable_date.dart';
import 'package:data_storage/models/representable_data_types/representable_decimal.dart';
import 'package:data_storage/models/representable_data_types/representable_integer.dart';
import 'package:data_storage/models/representable_data_types/representable_string.dart';
import 'package:data_storage/models/representable_data_types/representable_time.dart';
import 'package:flutter/material.dart';

class Data {
  Data.standard() {
    name = "";
    description = null;
    type = null;
  }

  Data({required this.name, this.description, required this.type});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      name: json["name"],
      description: json["description"],
      type: RepresentableDataType.fromJson(json["type"]),
    );
  }
  late String name;
  late String? description;
  late RepresentableDataType?
      type; // This defines the type of the value with some other features

  Widget getHistoric() {
    if (type is RepresentableInteger) {
      return IntegerHistoric(data: this);
    } else if (type is RepresentableDecimal) {
      return DecimalHistoric(data: this);
    } else if (type is RepresentableString) {
      return StringHistoric(data: this);
    } else if (type is RepresentableBoolean) {
      return BooleanHistoric(data: this);
    } else if (type is RepresentableTime) {
      return TimeHistoric(data: this);
    } else if (type is RepresentableDate) {
      return DateHistoric(data: this);
    } else {
      throw Exception(
          "Type error: the type ${type.runtimeType} is not a valid type");
    }
  }

  Widget getValueAdder() {
    if (type is RepresentableInteger) {
      return IntegerValueAdder(data: this);
    } else if (type is RepresentableDecimal) {
      return DecimalValueAdder(data: this);
    } else if (type is RepresentableString) {
      return StringValueAdder(data: this);
    } else if (type is RepresentableBoolean) {
      return BooleanValueAdder(data: this);
    } else if (type is RepresentableTime) {
      return TimeValueAdder(data: this);
    } else if (type is RepresentableDate) {
      return DateValueAdder(data: this);
    } else {
      throw Exception(
          "Type error: the type ${type.runtimeType} is not a valid type");
    }
  }

  Widget getViewer() {
    if (type is RepresentableInteger) {
      return IntegerViewer(data: this);
    } else if (type is RepresentableDecimal) {
      return DecimalViewer(data: this);
    } else if (type is RepresentableString) {
      return StringViewer(data: this);
    } else if (type is RepresentableBoolean) {
      return BooleanViewer(data: this);
    } else if (type is RepresentableTime) {
      return TimeViewer(data: this);
    } else if (type is RepresentableDate) {
      return DateViewer(data: this);
    } else {
      throw Exception(
          "Type error: the type ${type.runtimeType} is not a valid type");
    }
  }

  bool addValue(dynamic value) {
    /// Return false if the value wasn't add, else true
    String time = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    if (type is RepresentableInteger) {
      int tmp;
      if (value is! int) {
        if (value is String) {
          try {
            tmp = int.parse(value);
          } catch (_) {
            return false;
          }
        } else if (value is num) {
          tmp = value.toInt();
        } else {
          return false;
        }
      } else {
        tmp = value;
      }
      // ignore: unnecessary_cast
      type?.values.addAll({time: tmp}
          as Map<String, int>); // The cast is need, else it does not work (idk)
      return true;
    } else if (type is RepresentableDecimal) {
      num tmp;
      if (value is! num) {
        if (value is String) {
          try {
            tmp = num.parse(value);
          } catch (_) {
            return false;
          }
        } else {
          return false;
        }
      } else {
        tmp = value;
      }
      // ignore: unnecessary_cast
      type?.values.addAll({time: tmp.roundToDecimalPlaces(10)}
          as Map<String, num>); // The cast is need, else it does not work (idk)
      return true;
    } else if (type is RepresentableString) {
      // ignore: unnecessary_cast
      type?.values.addAll({time: value.toString()} as Map<String,
          String>); // The cast is need, else it does not work (idk)
      return true;
    } else if (type is RepresentableBoolean) {
      if (value is! bool) {
        try {
          // ignore: unnecessary_cast
          type?.values.addAll({time: bool.parse(value, caseSensitive: false)}
              as Map<String,
                  bool>); // The cast is need, else it does not work (idk)
          return true;
        } catch (_) {
          return false;
        }
      } else {
        // ignore: unnecessary_cast
        type?.values.addAll({time: value} as Map<String,
            bool>); // The cast is need, else it does not work (idk)
        return true;
      }
    } else if (type is RepresentableTime && value is TimeOfDay) {
      // ignore: unnecessary_cast
      type?.values.addAll({time: value} as Map<String,
          TimeOfDay>); // The cast is need, else it does not work (idk)
      return true;
    } else if (type is RepresentableDate && value is DateTime) {
      // ignore: unnecessary_cast
      type?.values.addAll({time: value} as Map<String,
          DateTime>); // The cast is need, else it does not work (idk)
      return true;
    }
    return false;
  }

  String get typeId =>
      {
        RepresentableInteger: "integer",
        RepresentableString: "string",
        RepresentableDecimal: "decimal",
        RepresentableBoolean: "boolean",
        RepresentableTime: "time",
        RepresentableDate: "date"
      }[type.runtimeType] ??
      "unknwonType";

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "type": type?.toJson(),
    };
  }
}
