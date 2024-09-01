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
                AppLocalizations.of(context)!.locale,
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
                      title: Text(AppLocalizations.of(context)!.dateFormat),
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
                      title: Text(AppLocalizations.of(context)!.use24H),
                      subtitle: Text(AppLocalizations.of(context)!.explaint24H),
                      trailing: Switch.adaptive(
                          value: context.watch<Settings>().use24H,
                          onChanged: (value) =>
                              context.read<Settings>().use24H = value),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0, top: 0, right: 8.0, left: 16.0),
                      child: Text(
                        AppLocalizations.of(context)!.explainDateTimeFormats(
                            DateTime.now().formatDateTimeLocalized(context)),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                AppLocalizations.of(context)!.yourData,
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
                                  var directory = await FilePicker.platform
                                      .getDirectoryPath();

                                  if (directory == null){
                                    throw Exception("File Creation Aborted!");
                                  }

                                  final file = File(
                                      '$directory/exported_collections_data_storage.json');

                                  await file.writeAsString(
                                      await FileManager.getUserData());
                                  if (context.mounted) {
                                    _showSnackBar(
                                      context,
                                      Text(AppLocalizations.of(context)!
                                          .fileCreatedAt(file.path)),
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
                                      Text(AppLocalizations.of(context)!
                                          .cannotCreateFile),
                                      SnackBarAction(
                                        label: AppLocalizations.of(context)!
                                            .seeWhy,
                                        onPressed: () {
                                          showAdaptiveDialog(
                                            context: context,
                                            builder: (context) =>
                                                AlertDialog.adaptive(
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .fileCreationError),
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
                              label: Text(AppLocalizations.of(context)!
                                  .exportCollections),
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
                                        if (context.mounted) {
                                          throw Exception(
                                              AppLocalizations.of(context)!
                                                  .fileErrImportEmpty(
                                                      fileContent.toString()));
                                        } else {
                                          throw Exception(
                                              "File Content Error (not fatal): the file seems to be empty and for this it cannot be imported.\n The content is $fileContent");
                                        }
                                      } else if ((await FileManager
                                              .getDataStorage())
                                          .isEmpty) {
                                        FileManager.saveUserData(
                                            jsonEncode(fileContent));
                                        if (context.mounted) {
                                          _showSnackBar(
                                              context,
                                              Text(AppLocalizations.of(context)!
                                                  .allCollectionsImported));
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
                                      if (context.mounted) {
                                        throw Exception(
                                            AppLocalizations.of(context)!
                                                .typeErrFileContent(
                                                    fileContent.runtimeType
                                                        .toString(),
                                                    fileContent.toString()));
                                      } else {
                                        throw Exception(
                                            "Type Error: the type ${fileContent.runtimeType} is not a valid type.\nThe content of the imported file is: $fileContent");
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      _showSnackBar(
                                        context,
                                        Text(AppLocalizations.of(context)!
                                            .cannotLoadFileContent),
                                        SnackBarAction(
                                          label: AppLocalizations.of(context)!
                                              .seeWhy,
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AlertDialog.adaptive(
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .fileLoadError),
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
                              label: Text(AppLocalizations.of(context)!
                                  .importCollections),
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
