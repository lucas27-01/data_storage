import 'dart:convert';

import 'package:data_storage/extensions/date_extensions.dart';
import 'package:data_storage/utils/file_manager.dart';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:data_storage/models/data_storage.dart';
import 'package:flutter/material.dart';

class DataValueAdder extends StatefulWidget {
  const DataValueAdder({
    super.key,
    required this.dataStorage,
    required this.onUpdateCollections,
    this.hangingCollections,
  });
  final DataStorage dataStorage;
  final Map<String, dynamic>? hangingCollections;
  final VoidCallback onUpdateCollections;

  @override
  State<DataValueAdder> createState() => _DataValueAdderState();
}

class _DataValueAdderState extends State<DataValueAdder> {
  late DataStorage dataStorage;
  final _formKey = GlobalKey<FormBuilderState>();

  void _showSnackBar(BuildContext context, Widget child,
      [SnackBarAction? action]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: child,
      action: action,
    ));
  }

  @override
  void initState() {
    dataStorage = widget.dataStorage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${dataStorage.name} value adder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                    "${AppLocalizations.of(context)!.name}: ${dataStorage.name}"),
                subtitle: dataStorage.description != null
                    ? Text(
                        "${AppLocalizations.of(context)!.description}: ${dataStorage.description}",
                      )
                    : null,
              ),
              for (var singleData in dataStorage.data)
                ExpandableSection(
                  isExpanded: true,
                  title: Text(
                    singleData.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (singleData.description != null)
                        Text(
                          "${AppLocalizations.of(context)!.description}: ${singleData.description}",
                        ),
                      Text(
                        "${AppLocalizations.of(context)!.type}: ${AppLocalizations.of(context)!.representableType(singleData.typeId)}",
                      ),
                      singleData.getHistoric(),
                      singleData.getValueAdder(
                        widget.hangingCollections?.entries
                            .firstWhere(
                              (test) => test.key == singleData.name,
                              orElse: () => const MapEntry("", null),
                            )
                            .value,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    bool canSave = true;
                    for (var entry in _formKey.currentState!.value.entries) {
                      //print("${entry.key}: ${entry.value}");
                      if (!dataStorage.data
                          .firstWhere((el) => el.name == entry.key)
                          .addValue(entry.value, )) {
                        _showSnackBar(
                          context,
                          Text(
                              "Something went wrong, cannot save ${entry.key}..."),
                        );
                        canSave = false;
                      }
                    }
                    if (canSave) {
                      removeHangingCollectionsById(dataStorage.id)
                          .then((_) => widget.onUpdateCollections);
                      dataStorage.updateLastChange();
                      Navigator.of(context).pop(dataStorage);
                    }
                    //print(jsonEncode(dataStorage));
                  }
                },
                label: Text(AppLocalizations.of(context)!.saveAndAdd),
                icon: const Icon(Icons.save_rounded),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: suspendValueAdding,
                      label: Text(AppLocalizations.of(context)!.suspendSaving),
                      icon: const Icon(Icons.pending_actions_rounded),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        showAdaptiveDialog(
                          context: context,
                          builder: (context) => AlertDialog.adaptive(
                            title: Text(AppLocalizations.of(context)!
                                .questionSuspendSaving),
                            content: SingleChildScrollView(
                              child: Text(AppLocalizations.of(context)!
                                  .explainSuspendSaving),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.help))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void suspendValueAdding() async {
    _formKey.currentState?.save();

    Map<(String, String), dynamic> hangingCollections = {};
    for (var entry in _formKey.currentState!.value.entries) {
      hangingCollections.addAll({
        (
          entry.key,
          dataStorage.data.firstWhere((test) => test.name == entry.key).typeId
        ): entry.value
      });
    }

    if (widget.hangingCollections?["id"] != null){
      await removeHangingCollectionsById(dataStorage.id);
    }

    saveHangingCollections(
      id: dataStorage.id,
      datas: hangingCollections,
    ).then((_) => widget.onUpdateCollections());
    Navigator.of(context).pop();
  }

  Future<void> removeHangingCollectionsById(int id) async {
    var rawHangingCollections =
        jsonDecode(await FileManager.getHangingCollections());

    if (rawHangingCollections?.isNotEmpty ?? false) {
      rawHangingCollections.removeWhere((test) => test["id"] == id);
      FileManager.saveHangingCollections(jsonEncode(rawHangingCollections));
    }

    // widget.onUpdateCollections();
  }
}

Future<void> saveHangingCollections({
  required int id,
  required Map<(String, String), dynamic> datas,
}) async {
  Map<String, dynamic> hangingCollections = {"id": id};
  for (var data in datas.entries) {
    hangingCollections.addAll({
      data.key.$1: <String, dynamic>{"_type": data.key.$2}
    });
    switch (data.value) {
      case null:
        hangingCollections[data.key.$1]["value"] = null;
        break;
      case bool _:
      case num _:
        hangingCollections[data.key.$1]["value"] ??= data.value;
        break;
      case String _:
        hangingCollections[data.key.$1]["value"] ??= data.value;
        break;
      case TimeOfDay _:
        hangingCollections[data.key.$1]["value"] =
            (data.value as TimeOfDay).toJson();
        break;
      case DateTime _:
        hangingCollections[data.key.$1]["value"] =
            (data.value as DateTime).toJson();
        break;
      default:
        throw Exception(
            "Type error: ${data.value.runtimeType} is not a valid type");
    }
  }

  // print(hangingCollections);

  // FileManager.getHangingCollections().then((v) => print(v));
  var savedHangingCollections =
      jsonDecode(await FileManager.getHangingCollections()) as List<dynamic>;

  savedHangingCollections.add(hangingCollections);
  // print(jsonEncode(savedHangingCollections));

  await FileManager.saveHangingCollections(jsonEncode(savedHangingCollections));
}
