import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

class FileManager {
  static Future<String> get _localPath async {
    Directory directory;
    if (Platform.isLinux) {
      directory = Directory(
        join(
          (await getApplicationDocumentsDirectory()).path,
          "data_storage",
        ),
      );
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    if (!await directory.exists()) await directory.create();
    return directory.path;
  }

  static Future<File> get _settingsFile async {
    var settingsFile = File(join(await _localPath, "app_settings.json"));
    if (!await settingsFile.exists()) {
      await settingsFile
          .writeAsString(jsonEncode(Settings.standard().toJson()));
    }
    return settingsFile;
  }

  static Future<File> get _userDataFile async {
    final path = await _localPath;
    File dataStorageFile = File(join(path, "user_data.json"));
    if (!await dataStorageFile.exists()) {
      dataStorageFile.writeAsString('[]');
    }
    return dataStorageFile;
  }

  static Future<File> get _hangingCollectionsFile async {
    File hangingCollectionsFile =
        File(join(await _localPath, "hanging_collections.json"));
    if (!await hangingCollectionsFile.exists()) {
      await hangingCollectionsFile.writeAsString("[]");
    }
    return hangingCollectionsFile;
  }

  static Future<void> saveSettings(String data) async {
    final file = await _settingsFile;
    file.writeAsString(data);
  }

  static Future<void> saveUserData(String data) async {
    final file = await _userDataFile;
    file.writeAsString(data);
  }

  static Future<void> saveHangingCollections(String data) async {
    await (await _hangingCollectionsFile).writeAsString(data);
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

  static Future<String> getHangingCollections() async {
    return await (await _hangingCollectionsFile).readAsString();
  }

  static Future<List<DataStorage>> getDataStorage() async {
    var tmpDS = jsonDecode(await FileManager.getUserData())
        .map((el) => DataStorage.fromJson(el))
        .toList();
    List<DataStorage> listDataStorage = [];
    for (var ds in tmpDS) {
      if (ds is DataStorage) {
        listDataStorage.add(ds);
      }
    }
    return listDataStorage;
  }

  static Stream<List<DataStorage>> getDataStorageStream() async* {
    var dsFile = await _userDataFile;

    final fileWatcher = FileWatcher(dsFile.path);
    final controller = StreamController<List<DataStorage>>();

    fileWatcher.events.listen((event) {
      if (event.type == ChangeType.MODIFY) {
        try {
          final content = dsFile.readAsStringSync();
          var tmpDS = jsonDecode(content)
              .map((el) => DataStorage.fromJson(el))
              .toList();
          List<DataStorage> listDataStorage = [];
          for (var ds in tmpDS) {
            if (ds is DataStorage) {
              listDataStorage.add(ds);
            }
          }
          controller.add(listDataStorage);
        } catch (e) {
          controller.addError(e);
        }
      }
    });

    try {
      controller.add(await getDataStorage());
    } catch (e) {
      controller.addError("Initial Reading Error $e");
      rethrow;
    }

    yield* controller.stream;
  }
}
