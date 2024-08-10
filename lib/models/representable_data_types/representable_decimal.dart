import 'package:data_storage/models/data_constraints/decimal_constraints.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';

class RepresentableDecimal extends RepresentableDataType {
  RepresentableDecimal.standard() : super.standard() {
    values = {};
    defaultValue = null;
    constraints = DecimalConstraints.standard();
  }

  RepresentableDecimal({
    required this.values,
    this.defaultValue,
    DecimalConstraints? constraints,
  }) : super.standard() {
    this.constraints = constraints ?? DecimalConstraints.standard();
  }

  factory RepresentableDecimal.fromJson(Map<String, dynamic> json) {
    return RepresentableDecimal(
      values: json["values"],
      defaultValue: json["defaultValue"],
      constraints: DecimalConstraints.fromJson(json["constraints"]),
    );
  }

  late Map<String, double> values;
  @override
  late double? defaultValue;
  @override
  late DecimalConstraints constraints;

  //Widget get builderWidget => const RepresentableIntegerAdder();

  @override
  Map<String, dynamic> toJson() {
    return {
      "_type": "RepresentableInteger",
      "values": values,
      "defaultValue": defaultValue,
      "constraints": constraints.toJson(),
    };
  }
}
