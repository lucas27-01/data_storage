import 'package:data_storage/widgets/expandable_section.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:data_storage/models/data_storage.dart';
import 'package:flutter/material.dart';

class DataValueAdder extends StatefulWidget {
  const DataValueAdder({super.key, required this.dataStorage});
  final DataStorage dataStorage;

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
                      singleData.getValueAdder(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    bool canSave = true;
                    for (var entry in _formKey.currentState!.value.entries) {
                      //print("${entry.key}: ${entry.value}");
                      if (!dataStorage.data
                          .firstWhere((el) => el.name == entry.key)
                          .addValue(entry.value)) {
                        _showSnackBar(
                          context,
                          Text(
                              "Something went wrong, cannot save ${entry.key}..."),
                        );
                        canSave = false;
                      }
                    }
                    if (canSave) {
                      dataStorage.updateLastChange();
                      Navigator.of(context).pop(dataStorage);
                    }
                    //print(jsonEncode(dataStorage));
                  }
                },
                label: Text(AppLocalizations.of(context)!.saveAndAdd),
                icon: const Icon(Icons.save_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
