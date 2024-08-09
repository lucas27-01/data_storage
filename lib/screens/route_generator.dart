import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/screens/data_storage_creator.dart';
import 'package:data_storage/screens/data_storage_viewer.dart';
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
        return MaterialPageRoute(
          builder: (context) => const DataStorageCreator(),
        );
      default:
        throw Exception("Error occurred");
    }
  }
}
