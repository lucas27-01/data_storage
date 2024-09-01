import 'package:data_storage/extensions/date_extensions.dart';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/data_constraints/string_constraints.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RepresentableString extends RepresentableDataType {
  RepresentableString.standard() : super.standard() {
    values = {};
    defaultValue = null;
    constraints = StringConstraints.standard();
    statsToSee = VisibleStringInfo.values.toSet();
  }

  RepresentableString({
    required this.values,
    required this.statsToSee,
    this.defaultValue,
    StringConstraints? constraints,
  }) : super.standard() {
    this.constraints = constraints ?? StringConstraints.standard();
  }

  factory RepresentableString.fromJson(Map<String, dynamic> json) {
    return RepresentableString(
      values: {
        for (var entry in json["values"].entries) entry.key: entry.value
      },
      statsToSee: {
        for (var stat in json["statsToSee"]
            .map((name) =>
                VisibleStringInfo.values.firstWhere((el) => el.name == name))
            .toSet())
          stat
      },
      defaultValue: json["defaultValue"],
      constraints: StringConstraints.fromJson(json["constraints"]),
    );
  }

  @override
  late Map<String, String>
      values; // Secs from Unix Epoch that represents value added and the value
  @override
  late String? defaultValue;
  @override
  late StringConstraints constraints;
  @override
  late Set<VisibleStringInfo> statsToSee = {};

  @override
  Widget builderWidget({Data? dataToEdit}) {
    return RepresentableStringAdder(
      dataToEdit: dataToEdit,
    );
  }

  @override
  Type get wantedType => String;

  @override
  String getStat({required BuildContext context, required dynamic stat}) {
    if (stat is VisibleStringInfo) {
      switch (stat) {
        case VisibleStringInfo.totalValuesNum:
          return values.length.toString();
        case VisibleStringInfo.mode:
          if (values.isNotEmpty) {
            Map<String, int> counter = {};
            for (var string in values.values) {
              counter[string] = (counter[string] ?? 0) + 1;
            }
            int maxOccurrences = counter.values.reduce((a, b) => a > b ? a : b);

            String mode = "";
            counter.forEach((string, occurrences) {
              if (occurrences == maxOccurrences) {
                mode += "$string, ";
              }
            });
            return AppLocalizations.of(context)!.modeWithOccurrences(
                mode.substring(0, mode.length - 2), maxOccurrences);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleStringInfo.shorterValue:
          if (values.isNotEmpty) {
            String shorterString =
                values.values.reduce((a, b) => a.length < b.length ? a : b);
            return AppLocalizations.of(context)!
                .stringWithChars(shorterString, shorterString.length);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleStringInfo.longerValue:
          if (values.isNotEmpty) {
            String longerString =
                values.values.reduce((a, b) => a.length > b.length ? a : b);
            return AppLocalizations.of(context)!
                .stringWithChars(longerString, longerString.length);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleStringInfo.meanLenght:
          if (values.isNotEmpty) {
            return AppLocalizations.of(context)!.numberOfCharacters(
                values.values.reduce((a, b) => a + b).length);
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
      "_type": "RepresentableString",
      "values": values,
      "statsToSee": statsToSee.map((el) => el.name).toList(),
      "defaultValue": defaultValue,
      "constraints": constraints.toJson(),
    };
  }
}

enum VisibleStringInfo {
  totalValuesNum,
  mode, // The most commonly string in the list
  meanLenght, // The mean of every value lenght
  longerValue, // The longer value (string)
  shorterValue, // The shorter value (string)
}

class RepresentableStringAdder extends StatefulWidget {
  const RepresentableStringAdder({super.key, this.dataToEdit});
  final Data? dataToEdit;

  @override
  State<RepresentableStringAdder> createState() =>
      _RepresentableStringAdderState();
}

class _RepresentableStringAdderState extends State<RepresentableStringAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final Data _newData;
  String? defaultValue;
  int? minLength, maxLength, maxWordsCount, minWordsCount;
  bool onlyAlphabetical = false;
  Set<VisibleStringInfo> statsToSee = {};

  @override
  void initState() {
    _newData = widget.dataToEdit ??
        Data(name: "", type: RepresentableString.standard());

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
                        .questionDeleteAddingStringType),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.stringDataAdding),
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
                  FormBuilderTextField(
                    initialValue:
                        (_newData.type?.defaultValue ?? "").toString(),
                    name: 'defaultValue',
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.defaultValue),
                      hintText: AppLocalizations.of(context)!.dataDefaultValue,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        if (onlyAlphabetical)
                          FormBuilderValidators.alphabetical(
                              checkNullOrEmpty: false),
                        if (maxLength != null)
                          FormBuilderValidators.max(maxLength!,
                              checkNullOrEmpty: false),
                        if (minLength != null)
                          FormBuilderValidators.min(minLength!,
                              checkNullOrEmpty: false),
                      ],
                    ),
                  ),
                  FormBuilderCheckboxGroup<VisibleStringInfo>(
                    name: 'statsToSee',
                    initialValue: _newData.type?.statsToSee.toList(),
                    options: [
                      for (var info in VisibleStringInfo.values)
                        FormBuilderFieldOption(
                          value: info,
                          child: Text(
                            AppLocalizations.of(context)!.statTerms(info.name),
                          ),
                        )
                    ],
                    decoration: InputDecoration(
                        label: Text(
                            AppLocalizations.of(context)!.statsToSeeInHistoric),
                        helper: IconButton(
                            onPressed: () => showAdaptiveDialog(
                                  context: context,
                                  builder: (context) => AlertDialog.adaptive(
                                    title: Text(AppLocalizations.of(context)!
                                        .questionStatsToSee),
                                    content: SingleChildScrollView(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .explainStringStatsToSee)),
                                  ),
                                ),
                            icon: const Icon(Icons.help_outline_rounded))),
                  ),
                  Text(
                    AppLocalizations.of(context)!.constraintsSettings,
                    style: const TextStyle(fontSize: 24),
                  ),
                  FormBuilderTextField(
                    initialValue:
                        (_newData.type?.constraints.minLength ?? "").toString(),
                    name: 'minLength',
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.minLength),
                      hintText: AppLocalizations.of(context)!.dataMaxLength,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.integer(checkNullOrEmpty: false),
                        if (maxLength != null)
                          FormBuilderValidators.max(
                            maxLength!,
                            checkNullOrEmpty: false,
                          )
                      ],
                    ),
                  ),
                  FormBuilderTextField(
                    initialValue:
                        (_newData.type?.constraints.maxLength ?? "").toString(),
                    name: 'maxLength',
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.maxLength),
                      hintText: AppLocalizations.of(context)!.dataMaxLength,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.integer(checkNullOrEmpty: false),
                        if (minLength != null)
                          FormBuilderValidators.min(
                            minLength!,
                            checkNullOrEmpty: false,
                          )
                      ],
                    ),
                  ),
                  FormBuilderCheckbox(
                    title: Text(AppLocalizations.of(context)!.onlyAlphabetical),
                    subtitle: Text(
                        AppLocalizations.of(context)!.subtitleOnlyAphabetical),
                    initialValue: _newData.type?.constraints.onlyAlphabetical,
                    name: "onlyAlphabetical",
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
                        defaultValue =
                            _formKey.currentState?.value["defaultValue"];
                      } catch (_) {
                        defaultValue = null;
                      }

                      try {
                        statsToSee =
                            _formKey.currentState?.value["statsToSee"].toSet();
                      } catch (_) {
                        statsToSee = {};
                      }

                      try {
                        maxLength = int.parse(
                            _formKey.currentState?.value["maxLength"]);
                      } catch (_) {
                        maxLength = null;
                      }

                      try {
                        minLength = int.parse(
                            _formKey.currentState?.value["minLength"]);
                      } catch (_) {
                        minLength = null;
                      }

                      onlyAlphabetical =
                          _formKey.currentState?.value["onlyAlphabetical"];

                      setState(() {});
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        _newData.type = RepresentableString(
                          values: _newData.type?.values as Map<String, String>? ?? {},
                          statsToSee: statsToSee,
                          defaultValue: defaultValue,
                          constraints: StringConstraints(
                            maxLength: maxLength,
                            minLength: minLength,
                            onlyAlphabetical: onlyAlphabetical,
                          ),
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

class StringHistoric extends StatelessWidget {
  const StringHistoric({super.key, required this.data});
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
                entry.value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(entry.key) * 1000)
                  .formatDateTimeLocalized(context)),
            ),
          const Divider(),
        ],
      ),
    );
  }
}

class StringValueAdder extends StatelessWidget {
  const StringValueAdder({super.key, required this.data});
  final Data data;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: data.name,
      initialValue: data.type?.defaultValue,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        label: Text("${AppLocalizations.of(context)!.stringValue}*"),
        hintText: AppLocalizations.of(context)!.stringValue,
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        if (data.type?.constraints.minLength != null)
          FormBuilderValidators.minLength(data.type!.constraints.minLength),
        if (data.type?.constraints.maxLength != null)
          FormBuilderValidators.maxLength(data.type!.constraints.maxLength),
        if (data.type?.constraints.onlyAlphabetical ?? false)
          FormBuilderValidators.alphabetical()
      ]),
    );
  }
}

class StringViewer extends StatelessWidget {
  const StringViewer({super.key, required this.data});
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
        for (VisibleStringInfo stat in data.type?.statsToSee)
          Text(
            "${AppLocalizations.of(context)!.statTerms(stat.name)}: ${data.type?.getStat(context: context, stat: stat)}",
          ),
        data.getHistoric(),
      ],
    );
  }
}
