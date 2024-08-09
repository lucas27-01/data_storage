import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_storage/providers/settings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<String> get _localPath async {
    var directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _settingsFile async {
    final path = await _localPath;
    return File(join(path, "app_settings.json"));
  }

  static Future<File> get _userDataFile async {
    final path = await _localPath;
    return File(join(path, "user_data.json"));
  }

  static Future<void> saveSettings(String data) async {
    final file = await _settingsFile;
    file.writeAsString(data);
  }

  static Future<void> saveUserData(String data) async {
    final file = await _userDataFile;
    file.writeAsString(data);
  }

  static Future<String> getSettings() async {
    try {
      final file = await _settingsFile;
      return await file.readAsString();
    } on FileSystemException {
      await saveSettings(jsonEncode(Settings.standard().toJson()));
      return jsonEncode(Settings.standard());
    }
  }

  static Future<String> getUserData() async {
    try {
      final file = await _userDataFile;
      return await file.readAsString();
    } on FileSystemException {
      await saveUserData("[]");
      return "[]";
    }
  }
}
