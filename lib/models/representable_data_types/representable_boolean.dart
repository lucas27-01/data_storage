import 'package:data_storage/extensions/date_extensions.dart';
import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RepresentableBoolean extends RepresentableDataType {
  RepresentableBoolean.standard() : super.standard() {
    values = {};
    defaultValue = null;
    statsToSee.addAll(VisibleBooleanInfo.values);
  }

  RepresentableBoolean({
    required this.values,
    required this.statsToSee,
    this.defaultValue,
  }) : super.standard();

  factory RepresentableBoolean.fromJson(Map<String, dynamic> json) {
    return RepresentableBoolean(
      values: {
        for (var entry in json["values"].entries) entry.key: entry.value
      },
      statsToSee: {
        for (var stat in json["statsToSee"]
            .map((name) =>
                VisibleBooleanInfo.values.firstWhere((el) => el.name == name))
            .toSet())
          stat
      },
      defaultValue: json["defaultValue"],
    );
  }

  @override
  late Map<String, bool> values;
  @override
  late bool? defaultValue;
  @override
  get constraints => null;
  @override
  late Set<VisibleBooleanInfo> statsToSee = {};

  @override
  Widget builderWidget({Data? dataToEdit}) {
    return RepresentableBooleanAdder(
      dataToEdit: dataToEdit,
    );
  }

  @override
  Type get wantedType => bool;

  @override
  String getStat({required BuildContext context, required dynamic stat}) {
    if (stat is VisibleBooleanInfo) {
      switch (stat) {
        case VisibleBooleanInfo.totalValuesNum:
          if (values.isNotEmpty) {
            return values.length.toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleBooleanInfo.mode:
          if (values.isNotEmpty) {
            Map<bool, int> counter = {};
            for (var boolean in values.values) {
              counter[boolean] = (counter[boolean] ?? 0) + 1;
            }
            int maxOccurrences = counter.values.reduce((a, b) => a > b ? a : b);

            String mode = "";
            counter.forEach((boolean, occurrences) {
              if (occurrences == maxOccurrences) {
                mode +=
                    "${boolean ? AppLocalizations.of(context)!.true_ : AppLocalizations.of(context)!.false_}, ";
              }
            });
            return AppLocalizations.of(context)!.modeWithOccurrences(
                mode.substring(0, mode.length - 2), maxOccurrences);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleBooleanInfo.trueNum:
          if (values.isNotEmpty) {
            return values.values
                .skipWhile((el) => el == true)
                .length
                .toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleBooleanInfo.falseNum:
          if (values.isNotEmpty) {
            return values.values
                .skipWhile((el) => el == false)
                .length
                .toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
      }
    } else {
      throw Exception("Type Error: ${stat.runtimeType} Unknown Type");
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "_type": "RepresentableBoolean",
      "values": values,
      "statsToSee": statsToSee.map((el) => el.name).toList(),
      "defaultValue": defaultValue,
    };
  }
}

enum VisibleBooleanInfo {
  totalValuesNum,
  trueNum,
  falseNum,
  mode,
}

class RepresentableBooleanAdder extends StatefulWidget {
  const RepresentableBooleanAdder({super.key, this.dataToEdit});
  final Data? dataToEdit;

  @override
  State<RepresentableBooleanAdder> createState() =>
      _RepresentableBooleanAdderState();
}

class _RepresentableBooleanAdderState extends State<RepresentableBooleanAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final Data _newData;
  Set<VisibleBooleanInfo> statsToSee = {};

  @override
  void initState() {
    _newData = widget.dataToEdit ??
        Data(name: "", type: RepresentableBoolean.standard());
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
                        child: Text(AppLocalizations.of(context)!.yesIWant)),
                    FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context)!.noStay))
                  ],
                  content: SingleChildScrollView(
                    child: Text(AppLocalizations.of(context)!
                        .questionDeleteAddingBooleanType),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.booleanDataAdding),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormBuilder(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.dataSettings,
                    style: const TextStyle(fontSize: 24),
                  ),
                  FormBuilderTextField(
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    initialValue: _newData.name,
                    name: 'name',
                    decoration: InputDecoration(
                      label: Text("${AppLocalizations.of(context)!.name}*"),
                      hintText: AppLocalizations.of(context)!.dataName,
                    ),
                    maxLength: 15,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(15),
                      FormBuilderValidators.minLength(3),
                    ]),
                  ),
                  FormBuilderTextField(
                    initialValue: _newData.description,
                    name: "description",
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.description),
                      hintText: AppLocalizations.of(context)!.dataDescription,
                    ),
                    maxLength: 50,
                    validator: FormBuilderValidators.maxLength(
                      50,
                      checkNullOrEmpty: false,
                    ),
                  ),
                  FormBuilderRadioGroup(
                    name: 'defaultValue',
                    initialValue: _newData.type?.defaultValue,
                    options: [
                      FormBuilderFieldOption<bool?>(
                        value: null,
                        child:
                            Text(AppLocalizations.of(context)!.noDefaultValue),
                      ),
                      FormBuilderFieldOption<bool?>(
                        value: true,
                        child: Text(AppLocalizations.of(context)!.true_),
                      ),
                      FormBuilderFieldOption<bool?>(
                        value: false,
                        child: Text(AppLocalizations.of(context)!.false_),
                      ),
                    ],
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.defaultValue),
                    ),
                  ),
                  FormBuilderCheckboxGroup(
                    name: "statsToSee",
                    options: [
                      for (var info in VisibleBooleanInfo.values)
                        FormBuilderFieldOption(
                          value: info,
                          child: Text(
                            AppLocalizations.of(context)!.statTerms(info.name),
                          ),
                        )
                    ],
                    initialValue: _newData.type?.statsToSee.toList(),
                    decoration: InputDecoration(
                        label: Text(
                            AppLocalizations.of(context)!.statsToSeeInHistoric),
                        helper: IconButton(
                            onPressed: () => showAdaptiveDialog(
                                  context: context,
                                  builder: (contex) => AlertDialog.adaptive(
                                    title: Text(AppLocalizations.of(context)!
                                        .questionStatsToSee),
                                    content: SingleChildScrollView(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .explainBooleanStatsToSee)),
                                  ),
                                ),
                            icon: const Icon(Icons.help_outline_rounded))),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _formKey.currentState?.save();

                      _newData.name =
                          _formKey.currentState?.value["name"] ?? '';
                      _newData.description =
                          _formKey.currentState?.value["description"];

                      try {
                        statsToSee =
                            _formKey.currentState?.value["statsToSee"].toSet();
                      } catch (_) {
                        statsToSee = {};
                      }

                      setState(() {});
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        _newData.type = RepresentableBoolean(
                          values: {},
                          statsToSee: statsToSee,
                          defaultValue:
                              _formKey.currentState?.value['defaultValue'],
                        );
                        Navigator.pop(context, _newData);
                      }
                    },
                    label: Text(AppLocalizations.of(context)!.saveAndAdd),
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BooleanHistoric extends StatelessWidget {
  const BooleanHistoric({super.key, required this.data});
  final Data data;

  @override
  Widget build(BuildContext context) {
    return ExpandableSection(
      title: Text(
        "${AppLocalizations.of(context)!.historicOf} ${data.name}",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        children: [
          for (var entry in data.type!.values.entries.toList().reversed) 
            ListTile(
              title: Text(
                entry.value
                    ? AppLocalizations.of(context)!.true_
                    : AppLocalizations.of(context)!.false_,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(entry.key) * 1000)
                  .formatDateTimeLocalized(context)),
            ),
          const Divider()
        ],
      ),
    );
  }
}

class BooleanValueAdder extends StatelessWidget {
  const BooleanValueAdder({super.key, required this.data});
  final Data data;

  @override
  Widget build(BuildContext context) {
    return FormBuilderSwitch(
      name: data.name,
      initialValue: data.type?.defaultValue,
      title: Text(
        AppLocalizations.of(context)!.booleanValue,
        style: const TextStyle(fontSize: 16),
      ),
      validator: FormBuilderValidators.required(),
    );
  }
}

class BooleanViewer extends StatelessWidget {
  const BooleanViewer({super.key, required this.data});
  final Data data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.description != null)
          Text(
              "${AppLocalizations.of(context)!.description}: ${data.description!}"),
        if (data.description != null) const Divider(),
        for (VisibleBooleanInfo stat in data.type?.statsToSee)
          Text(
            "${AppLocalizations.of(context)!.statTerms(stat.name)}: ${data.type?.getStat(context: context, stat: stat)}",
          ),
        data.getHistoric(),
      ],
    );
  }
}
