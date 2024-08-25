import 'package:data_storage/extensions/date_extensions.dart';
import 'package:data_storage/models/data.dart';

class DataStorage {
  DataStorage.standard() {
    lastChange = id =
        DateTime.now().secondsSinceEpoch; // The seconds since the Unix Epoch
    name = "";
    description = null;
    fromTemplate = false;
    data = [];
  }

  DataStorage({
    required this.name,
    required this.data,
    int? lastChange,
    this.description,
    this.fromTemplate = false,
  }) {
    id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    this.lastChange = lastChange ?? DateTime.now().secondsSinceEpoch;
  }

  DataStorage.withId({
    required this.id,
    required this.name,
    required this.data,
    required this.lastChange,
    this.description,
    this.fromTemplate = false,
  });

  factory DataStorage.fromJson(Map<String, dynamic> json) {
    return DataStorage.withId(
      id: json["id"],
      name: json["name"],
      lastChange: json["lastChange"],
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
  late int lastChange;
  late String name;
  late String? description;
  late bool fromTemplate;
  late List<Data> data;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "lastChange": lastChange,
      "description": description,
      "fromTemplate": fromTemplate,
      "data": data.map((el) => el.toJson()).toList()
    };
  }

  DateTime creationDate() {
    return DateTimeExtensions.fromSecondsSinceEpoch(id * 1000);
  }

  DateTime get getLastChange =>
      DateTimeExtensions.fromSecondsSinceEpoch(lastChange * 1000);

  void updateLastChange() => lastChange = DateTime.now().secondsSinceEpoch;
}
