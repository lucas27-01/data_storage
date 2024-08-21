import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/screens/data_storage_creator.dart';
import 'package:data_storage/screens/data_storage_viewer.dart';
import 'package:data_storage/screens/data_value_adder.dart';
import 'package:data_storage/screens/settings.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/settings":
        return MaterialPageRoute(builder: (context) => const SettingsPage());
      case "/dataStorageViewer":
        if (args is DataStorage) {
          return MaterialPageRoute(
              builder: (context) => DataStorageViewer(dataStorage: args));
        } else {
          throw Exception("Error occurred");
        }
      case "/dataStorageCreator":
        if (args is DataStorage) {
          return MaterialPageRoute<DataStorage?>(
            builder: (context) => DataStorageCreator(
              dataStorageToEdit: args,
            ),
          );
        } else if (args == null) {
          return MaterialPageRoute<DataStorage?>(
            builder: (context) => const DataStorageCreator(),
          );
        } else {
          throw Exception("Error occurred");
        }
      case "/dataValueAdder":
        if (args is DataStorage){
          return MaterialPageRoute<DataStorage?>(builder: (context) => DataValueAdder(dataStorage: args));
        } else {
          throw Exception("Error occurred");
        }
      default:
        throw Exception("Error occurred");
    }
  }
}
