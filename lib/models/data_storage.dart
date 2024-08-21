import 'package:data_storage/models/data.dart';

class DataStorage {
  DataStorage.standard() {
    id = (DateTime.now().millisecondsSinceEpoch / 1000)
        .truncate(); // The seconds since the Unix Epoch
    name = "";
    description = null;
    fromTemplate = false;
    data = [];
  }

  DataStorage({
    required this.name,
    required this.data,
    this.description,
    this.fromTemplate = false,
  }) {
    id = (DateTime.now().millisecondsSinceEpoch / 1000).truncate();
  }

  DataStorage.withId({
    required this.id,
    required this.name,
    required this.data,
    this.description,
    this.fromTemplate = false,
  });

  factory DataStorage.fromJson(Map<String, dynamic> json) {
    return DataStorage.withId(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      fromTemplate: json["fromTemplate"],
      data: [
        for (var singleData
            in json["data"].map((el) => Data.fromJson(el)).toList())
          singleData
      ],
    );
  }

  late int id;
  late String name;
  late String? description;
  late bool fromTemplate;
  late List<Data> data;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "fromTemplate": fromTemplate,
      "data": data.map((el) => el.toJson()).toList()
    };
  }

  DateTime creationDate() {
    return DateTime.fromMillisecondsSinceEpoch(id * 1000);
  }
}
