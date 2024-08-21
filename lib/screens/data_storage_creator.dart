import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DataStorageCreator extends StatefulWidget {
  const DataStorageCreator({super.key, this.dataStorageToEdit});
  final DataStorage? dataStorageToEdit;

  @override
  State<DataStorageCreator> createState() => _DataStorageCreatorState();
}

class _DataStorageCreatorState extends State<DataStorageCreator> {
  int _selectedTabIndex = 0;
  final _genericFormKey = GlobalKey<FormBuilderState>();
  late DataStorage newDataStorage;
  bool _isGenericDataStorageInfoValid = false;

  @override
  void initState() {
    newDataStorage = widget.dataStorageToEdit ?? DataStorage.standard();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog.adaptive(
                      title: Text(AppLocalizations.of(context)!.attenction),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child:
                                Text(AppLocalizations.of(context)!.yesIWant)),
                        FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context)!.noStay))
                      ],
                      content: SingleChildScrollView(
                        child: Text(AppLocalizations.of(context)!
                            .questionDeleteCreationDS),
                      ),
                    );
                  })),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.createDataStorage),
        ),
        body: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormBuilder(
              key: _genericFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.genericCreateInfo),
                    FormBuilderTextField(
                      initialValue: newDataStorage.id.toString(),
                      enabled: false,
                      decoration: const InputDecoration(label: Text('id')),
                      name: 'id',
                    ),
                    FormBuilderTextField(
                      initialValue: newDataStorage.name,
                      maxLength: 20,
                      name: "name",
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.name),
                        hintText: AppLocalizations.of(context)!.dataStorageName,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxLength(20),
                        FormBuilderValidators.minLength(3)
                      ]),
                    ),
                    FormBuilderTextField(
                      initialValue: newDataStorage.description,
                      maxLength: 500,
                      name: "description",
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.description),
                        hintText: AppLocalizations.of(context)!
                            .dataStorageDescription,
                      ),
                      validator: FormBuilderValidators.maxLength(
                        500,
                        checkNullOrEmpty: false,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_genericFormKey.currentState?.saveAndValidate() ??
                            false) {
                          newDataStorage.name =
                              _genericFormKey.currentState!.value['name'];
                          newDataStorage.description = _genericFormKey
                              .currentState?.value["description"];
                          _isGenericDataStorageInfoValid = true;
                          setState(() => _selectedTabIndex = 1);
                        }
                      },
                      label:
                          Text(AppLocalizations.of(context)!.saveAndContinue),
                      icon: const Icon(Icons.check),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final typeFormKey = GlobalKey<FormBuilderState>();
                        var newData = await showDialog<Data?>(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              title: Text(
                                  '${AppLocalizations.of(context)!.selType}!'),
                              content: FormBuilder(
                                key: typeFormKey,
                                child: FormBuilderDropdown(
                                  decoration: InputDecoration(
                                    label: Text(
                                        AppLocalizations.of(context)!.selType),
                                    icon: const Icon(Icons.code),
                                  ),
                                  name: "type",
                                  validator: FormBuilderValidators.required(),
                                  items: [
                                    for (var entry in RepresentableDataType
                                        .representableDataTypes.entries)
                                      DropdownMenuItem(
                                        value: entry.key,
                                        child: Text(AppLocalizations.of(
                                                context)!
                                            .representableType(entry.value)),
                                      )
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton.icon(
                                  onPressed: () =>
                                      Navigator.of(context).pop(null),
                                  label: Text(
                                      AppLocalizations.of(context)!.cancel),
                                  icon: const Icon(Icons.cancel),
                                ),
                                FilledButton(
                                    onPressed: () {
                                      if (typeFormKey.currentState
                                              ?.saveAndValidate() ??
                                          false) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => typeFormKey
                                                .currentState!.value["type"]
                                                .builderWidget(),
                                          ),
                                        ).then((value) {
                                          if (context.mounted) {
                                            Navigator.pop(context, value);
                                          }
                                        });
                                      }
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .continuing)),
                              ],
                            );
                          },
                        );

                        if (newData != null) {
                          setState(
                            () => newDataStorage.data.add(newData),
                          );
                        }
                      },
                      label: Text(AppLocalizations.of(context)!.addData),
                      icon: const Icon(Icons.add_rounded),
                    ),
                    FilledButton.icon(
                      onPressed: newDataStorage.data.isEmpty ||
                              !_isGenericDataStorageInfoValid
                          ? null
                          : () => showAdaptiveDialog(
                                context: context,
                                builder: (context) => AlertDialog.adaptive(
                                  title: Text(
                                      AppLocalizations.of(context)!.attenction),
                                  content: SingleChildScrollView(
                                    child: Text(AppLocalizations.of(context)!
                                        .questionDataStorageCreationComplete),
                                  ),
                                  actions: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .pop(newDataStorage);
                                      },
                                      label: Text(AppLocalizations.of(context)!
                                          .yesIWant),
                                      icon: const Icon(Icons.add_rounded),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      label: Text(
                                          AppLocalizations.of(context)!.noStay),
                                      icon: const Icon(Icons.cancel_rounded),
                                    )
                                  ],
                                ),
                              ),
                      label: Text(AppLocalizations.of(context)!.saveAndAdd),
                      icon: const Icon(Icons.check_rounded),
                    )
                  ],
                ),
                const Divider(),
                for (int index = 0;
                    index < (newDataStorage.data.length);
                    index++)
                  ListTile(
                    leading: Icon(
                      RepresentableDataType.representableDataTypeAsIcon[
                          newDataStorage.data[index].type.runtimeType],
                    ),
                    title: Text(
                      newDataStorage.data[index].name,
                    ),
                    subtitle: newDataStorage.data[index].description != null
                        ? Text(
                            newDataStorage.data[index].description!,
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            var newData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => newDataStorage
                                    .data[index].type!
                                    .builderWidget(
                                        dataToEdit: newDataStorage.data[index]),
                              ),
                            );
                            if (newData != null) {
                              setState(
                                  () => newDataStorage.data[index] = newData);
                            }
                          },
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: () => showAdaptiveDialog(
                            context: context,
                            builder: (context) => AlertDialog.adaptive(
                              title: Text(
                                AppLocalizations.of(context)!.attenction,
                              ),
                              content: SingleChildScrollView(
                                child: Text(AppLocalizations.of(context)!
                                    .confirmDeleteData(
                                        newDataStorage.data[index].name,
                                        newDataStorage
                                                .data[index].description ??
                                            "")),
                              ),
                              actions: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(
                                      () => newDataStorage.data.removeAt(index),
                                    );
                                  },
                                  label: Text(
                                      AppLocalizations.of(context)!.delete),
                                  icon: const Icon(Icons.warning_rounded),
                                ),
                                FilledButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  label: Text(
                                      AppLocalizations.of(context)!.cancel),
                                  icon: const Icon(Icons.cancel_rounded),
                                ),
                              ],
                            ),
                          ),
                          icon: const Icon(CupertinoIcons.trash_fill),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          )
        ][_selectedTabIndex],
        bottomNavigationBar: BottomNavigationBar(
          elevation: 27,
          selectedIconTheme: const IconThemeData(size: 30),
          currentIndex: _selectedTabIndex,
          onTap: (value) => setState(() => _selectedTabIndex = value),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.info_rounded),
              label: AppLocalizations.of(context)!.generic,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.data_array_rounded),
              label: AppLocalizations.of(context)!.data,
            ),
          ],
        ),
      ),
    );
  }
}
