import 'package:data_storage/screens/settings.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/settings":
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
              builder: (context) => SettingsPage(
                    language: args,
                  ));
        } else {
          throw Exception("Error occurred");
        }
      default:
        throw Exception("Error occurred");
    }
  }
}
