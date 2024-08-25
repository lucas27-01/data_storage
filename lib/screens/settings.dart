import 'dart:convert';
import 'dart:io';

import 'package:data_storage/extensions/date_extensions.dart';
import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/models/theme_settings.dart';
import 'package:data_storage/models/user_settings.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:data_storage/utils/file_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  void _showSnackBar(BuildContext context, Widget child,
      [SnackBarAction? action]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: child,
      action: action,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsPageName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //leading: Icon(Icons.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.theme,
                  style: const TextStyle(
                      fontSize: 27, fontWeight: FontWeight.bold)),
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(context.watch<Settings>().brightnessTheme ==
                              Brightness.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded),
                      title:
                          Text(AppLocalizations.of(context)!.darkModeWithColon),
                      trailing: Switch(
                        value: context.watch<Settings>().brightnessTheme ==
                            Brightness.dark,
                        onChanged: (_) {
                          context.read<Settings>().reverseBrightnessTheme();
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                          AppLocalizations.of(context)!.themeColorWithColon),
                      leading: Icon(
                        Icons.color_lens,
                        color: context.watch<Settings>().colorTheme,
                      ),
                      trailing: DropdownButton<Color>(
                        value: context.watch<Settings>().colorTheme,
                        menuMaxHeight: 350,
                        onChanged: (value) {
                          context.read<Settings>().setColorTheme(color: value!);
                        },
                        items: [
                          for (var entry in ThemeSettings.colorNames.entries)
                            DropdownMenuItem<Color>(
                                value: entry.key,
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .color(entry.value),
                                    style: TextStyle(color: entry.key)))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Locale",
                style:
                    const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(AppLocalizations.of(context)!.langWithColon),
                      trailing: DropdownButton(
                        value: context.watch<Settings>().locale,
                        menuMaxHeight: 350,
                        onChanged: (value) =>
                            context.read<Settings>().setLocale(locale: value!),
                        items: [
                          for (var entry
                              in UserSettings.languagePerLocale.entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            )
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text("Date Format"),
                      leading: const Icon(Icons.date_range_rounded),
                      trailing: DropdownButton(
                        value: context.read<Settings>().dateFormat,
                        items: [
                          for (var entry
                              in UserSettings.dateFormatPerLocale.entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            )
                        ],
                        onChanged: (value) => context
                            .read<Settings>()
                            .setDateFormat(localeFormat: value),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time_rounded),
                      subtitle: Text("24 Hour format or AM/PM"),
                      title: Text("Use 24 Hour format"),
                      trailing: Switch.adaptive(
                          value: context.watch<Settings>().use24H,
                          onChanged: (value) =>
                              context.read<Settings>().use24H = value),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0, top: 0, right: 8.0, left: 16.0),
                      child: Text(
                        "How to display the date. With the current format today's date would be ${DateTime.now().formatDateTimeLocalized(context)}", // TODO: translate
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Your Data",
                style:
                    const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                try {
                                  Directory? directory;
                                  if (Platform.isAndroid) {
                                    directory = Directory(join(
                                      (await getExternalStorageDirectory())!
                                          .parent
                                          .parent
                                          .parent
                                          .parent
                                          .path,
                                      'Android',
                                      'media',
                                      'eu.luigicapp.data_storage',
                                    )); // To acces at /storage/emulated/0/Android/media/eu.luigicapp.data_storage

                                    directory
                                        .create(); // Only if dir doesn't exist
                                  } else {
                                    directory =
                                        await getApplicationDocumentsDirectory();
                                  }

                                  final file = File(
                                      '${directory.path}/exported_collections_data_storage.json');

                                  await file.writeAsString(
                                      await FileManager.getUserData());
                                  if (context.mounted) {
                                    _showSnackBar(
                                      context,
                                      Text("File created at ${file.path}"),
                                      SnackBarAction(
                                        label: AppLocalizations.of(context)!.ok,
                                        onPressed: () {},
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showSnackBar(
                                      context,
                                      Text("Couldn't create file"),
                                      SnackBarAction(
                                        label: "See why",
                                        onPressed: () {
                                          showAdaptiveDialog(
                                            context: context,
                                            builder: (context) =>
                                                AlertDialog.adaptive(
                                              title:
                                                  Text("File Creation Error"),
                                              content: SingleChildScrollView(
                                                child: Text(e.toString()),
                                              ),
                                              actions: [
                                                FilledButton.icon(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  label: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .ok),
                                                  icon: const Icon(
                                                      Icons.close_rounded),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }
                              },
                              label: Text("Export Collections"),
                              icon: const Icon(Icons.data_array_rounded),
                              //icon: const Icon(Icons.data_array_rounded),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['json'],
                                );
                                if (result != null &&
                                    result.files.single.path != null) {
                                  try {
                                    var fileContent = jsonDecode(
                                        await File(result.files.single.path!)
                                            .readAsString());
                                    if (fileContent is List<dynamic>) {
                                      if (fileContent.isEmpty) {
                                        throw Exception(
                                            "File Content Error (not fatal): the file seems to be empty and for this it cannot be imported.\n The content is $fileContent");
                                      } else if ((await FileManager
                                              .getDataStorage())
                                          .isEmpty) {
                                        FileManager.saveUserData(
                                            jsonEncode(fileContent));
                                        if (context.mounted) {
                                          _showSnackBar(
                                              context,
                                              Text(
                                                  "Every Collection Imported"));
                                        }
                                      } else {
                                        List<DataStorage> savedDataStorages =
                                            await FileManager.getDataStorage();
                                        List<DataStorage>
                                            dataStoragesFromImport = fileContent
                                                .map((el) =>
                                                    DataStorage.fromJson(el))
                                                .toList();
                                        List<DataStorage> newDataStorages = [];

                                        for (DataStorage singleDS
                                            in savedDataStorages) {
                                          DataStorage? importedDataStorage =
                                              dataStoragesFromImport.firstWhere(
                                                  (imported) =>
                                                      imported.id ==
                                                      singleDS.id);

                                          newDataStorages.add(singleDS
                                                      .lastChange >
                                                  importedDataStorage.lastChange
                                              ? singleDS
                                              : importedDataStorage);
                                        }

                                        FileManager.saveUserData(
                                            jsonEncode(newDataStorages));
                                      }
                                    } else {
                                      throw Exception(
                                          "Type Error: the type ${fileContent.runtimeType} is not a valid type.\nThe content of the imported file is: $fileContent");
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      _showSnackBar(
                                        context,
                                        Text("Cannot load file content"),
                                        SnackBarAction(
                                          label: "See why",
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AlertDialog.adaptive(
                                              title: Text("File Load Error"),
                                              content: SingleChildScrollView(
                                                child: Text(e.toString()),
                                              ),
                                              actions: [
                                                FilledButton.icon(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  label: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .ok),
                                                  icon: const Icon(
                                                      Icons.close_rounded),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              label: Text("Import Collections"),
                              icon: const Icon(Icons.import_export_rounded),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
