import 'package:data_storage/models/representable_data_types/representable_data_type.dart';

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

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "type": type?.toJson(),
    };
  }
}
