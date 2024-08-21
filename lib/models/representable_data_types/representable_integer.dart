import 'dart:math';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/data_constraints/integer_constraints.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:data_storage/extensions/date_extensions.dart';

class RepresentableInteger extends RepresentableDataType {
  RepresentableInteger.standard() : super.standard() {
    values = {};
    defaultValue = null;
    constraints = IntegerConstraints.standard();
    statsToSee.addAll(VisibleIntegerInfo.values);
  }

  RepresentableInteger({
    required this.values,
    required this.statsToSee,
    this.defaultValue,
    IntegerConstraints? constraints,
  }) : super.standard() {
    this.constraints = constraints ?? IntegerConstraints.standard();
  }

  factory RepresentableInteger.fromJson(Map<String, dynamic> json) {
    return RepresentableInteger(
      values: {
        for (var entry in json["values"].entries) entry.key: entry.value
      },
      statsToSee: {
        for (var stat in json["statsToSee"]
            .map((name) =>
                VisibleIntegerInfo.values.firstWhere((el) => el.name == name))
            .toSet())
          stat
      },
      defaultValue: json["defaultValue"],
      constraints: IntegerConstraints.fromJson(json["constraints"]),
    );
  }

  @override
  late Map<String, int> values;
  @override
  late int? defaultValue;
  @override
  late IntegerConstraints constraints;
  @override
  late Set<VisibleIntegerInfo> statsToSee = {};

  @override
  Widget builderWidget({Data? dataToEdit}) {
    return RepresentableIntegerAdder(
      dataToEdit: dataToEdit,
    );
  }

  @override
  Type get wantedType => int;

  @override
  String getStat({required BuildContext context, required dynamic stat}) {
    if (stat is VisibleIntegerInfo) {
      switch (stat) {
        case VisibleIntegerInfo.mean:
          if (values.isNotEmpty) {
            return (values.values.reduce((a, b) => a + b) / values.length)
                .toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleIntegerInfo.median:
          if (values.isNotEmpty) {
            List<int> sortedValues = List.from(values.values.toList());
            sortedValues.sort();
            if (sortedValues.length.isOdd) {
              return (sortedValues[sortedValues.length ~/ 2]).toString();
            } else {
              return ((sortedValues[sortedValues.length ~/ 2 - 1] +
                          sortedValues[sortedValues.length ~/ 2]) /
                      2)
                  .toString();
            }
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleIntegerInfo.mode:
          if (values.isNotEmpty) {
            Map<int, int> counter = {};
            for (var integer in values.values) {
              counter[integer] = (counter[integer] ?? 0) + 1;
            }
            int maxOccurrences = counter.values.reduce((a, b) => a > b ? a : b);

            String mode = "";
            counter.forEach((number, occurrences) {
              if (occurrences == maxOccurrences) {
                mode += "$number, ";
              }
            });
            return AppLocalizations.of(context)!.modeWithOccurrences(
                mode.substring(0, mode.length - 2), maxOccurrences);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleIntegerInfo.minValue:
          if (values.isNotEmpty) {
            return values.values.reduce((a, b) => a < b ? a : b).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleIntegerInfo.maxValue:
          if (values.isNotEmpty) {
            return values.values.reduce((a, b) => a > b ? a : b).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleIntegerInfo.standardDeviation:
          if (values.isNotEmpty) {
            num mean = (values.values.reduce((a, b) => a + b) / values.length);

            num variance = values.values
                    .map((number) => pow(number - mean, 2))
                    .reduce((a, b) => a + b) /
                values.length;
            return sqrt(variance).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleIntegerInfo.range:
          if (values.isNotEmpty) {
            return (values.values.reduce((a, b) => a > b ? a : b) -
                    values.values.reduce((a, b) => a < b ? a : b))
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
      "_type": "RepresentableInteger",
      "values": values,
      "statsToSee": statsToSee.map((el) => el.name).toList(),
      "defaultValue": defaultValue,
      "constraints": constraints.toJson(),
    };
  }
}

enum VisibleIntegerInfo {
  mean, // Mean value
  median, // The center value of the ordered list
  mode, // The most commonly number in the list
  maxValue, // The max Value in the list
  minValue, // The min Value in the list
  standardDeviation, // How much the numbers in the list deviate on average from the mean
  range // Max value - Min value
}

class RepresentableIntegerAdder extends StatefulWidget {
  const RepresentableIntegerAdder({super.key, this.dataToEdit});
  final Data? dataToEdit;

  @override
  State<RepresentableIntegerAdder> createState() =>
      _RepresentableIntegerAdderState();
}

class _RepresentableIntegerAdderState extends State<RepresentableIntegerAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final Data _newData;
  int? defaultValue, maxValue, minValue, multipleOf;
  Set<VisibleIntegerInfo> statsToSee = {};

  @override
  void initState() {
    _newData = widget.dataToEdit ??
        Data(name: "", type: RepresentableInteger.standard());
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
                        .questionDeleteAddingIntegerType),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.integerDataAdding),
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.defaultValue),
                      hintText: AppLocalizations.of(context)!.dataDefaultValue,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.integer(checkNullOrEmpty: false),
                        if (maxValue != null)
                          FormBuilderValidators.max(maxValue!,
                              checkNullOrEmpty: false),
                        if (minValue != null)
                          FormBuilderValidators.min(minValue!,
                              checkNullOrEmpty: false),
                      ],
                    ),
                  ),
                  FormBuilderCheckboxGroup(
                    name: "statsToSee",
                    options: [
                      for (var info in VisibleIntegerInfo.values)
                        FormBuilderFieldOption(
                            value: info,
                            child: Text(AppLocalizations.of(context)!
                                .statTerms(info.name)))
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
                                                .explainIntegerStatsToSee)),
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
                        (_newData.type?.constraints.minValue ?? "").toString(),
                    name: 'minValue',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.minValue),
                      hintText: AppLocalizations.of(context)!.dataDefaultValue,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.integer(checkNullOrEmpty: false),
                        if (maxValue != null)
                          FormBuilderValidators.max(
                            maxValue!,
                            checkNullOrEmpty: false,
                          )
                      ],
                    ),
                  ),
                  FormBuilderTextField(
                    initialValue:
                        (_newData.type?.constraints.maxValue ?? "").toString(),
                    name: 'maxValue',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.maxValue),
                      hintText: AppLocalizations.of(context)!.dataMaxValue,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.integer(checkNullOrEmpty: false),
                        if (minValue != null)
                          FormBuilderValidators.min(
                            minValue!,
                            checkNullOrEmpty: false,
                          )
                      ],
                    ),
                  ),
                  FormBuilderTextField(
                    initialValue: (_newData.type?.constraints.multipleOf ?? "")
                        .toString(),
                    name: "multipleOf",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.multipleOf),
                      hintText: AppLocalizations.of(context)!.valueMultipleOf,
                    ),
                    validator: FormBuilderValidators.compose(
                      [FormBuilderValidators.integer(checkNullOrEmpty: false)],
                    ),
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
                        defaultValue = int.parse(
                            _formKey.currentState?.value["defaultValue"]);
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
                        maxValue =
                            int.parse(_formKey.currentState?.value["maxValue"]);
                      } catch (_) {
                        maxValue = null;
                      }

                      try {
                        minValue =
                            int.parse(_formKey.currentState?.value["minValue"]);
                      } catch (_) {
                        minValue = null;
                      }

                      try {
                        multipleOf = int.parse(
                            _formKey.currentState?.value["multipleOf"]);
                      } catch (e) {
                        multipleOf = null;
                      }

                      setState(() {});
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        _newData.type = RepresentableInteger(
                          values: {},
                          statsToSee: statsToSee,
                          defaultValue: defaultValue,
                          constraints: IntegerConstraints(
                            maxValue: maxValue,
                            minValue: minValue,
                            multipleOf: multipleOf,
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

class IntegerHistoric extends StatelessWidget {
  const IntegerHistoric({super.key, required this.data});
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
          for (var entry in data.type!.values.entries)
            ListTile(
              title: Text(
                entry.value.toString(),
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

class IntegerValueAdder extends StatelessWidget {
  const IntegerValueAdder({super.key, required this.data});
  final Data data;

  @override
  Widget build(BuildContext context) {
    return data.type?.constraints.maxValue == null ||
            data.type?.constraints.minValue == null
        ? FormBuilderTextField(
            name: data.name,
            initialValue: (data.type?.defaultValue ?? "").toString(),
            autovalidateMode: AutovalidateMode.onUnfocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              label: Text("${AppLocalizations.of(context)!.integerValue}*"),
              hintText: AppLocalizations.of(context)!.integerValue,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.integer(),
              FormBuilderValidators.required(),
              if (data.type?.constraints.maxValue != null)
                FormBuilderValidators.max(data.type!.constraints.maxValue),
              if (data.type?.constraints.minValue != null)
                FormBuilderValidators.min(data.type!.constraints.minValue),
              if (data.type?.constraints.multipleOf != null)
                (value) {
                  final number = int.tryParse(value!);
                  if (number == null) {
                    return null;
                  }
                  if (number % data.type!.constraints.multipleOf != 0) {
                    return AppLocalizations.of(context)!
                        .multipleOfNum(data.type!.constraints.multipleOf);
                  }
                  return null;
                }
            ]),
          )
        : FormBuilderSlider(
            name: data.name,
            initialValue:
                (data.type?.defaultValue ?? data.type!.constraints.minValue) *
                    1.0,
            min: data.type!.constraints.minValue * 1.0,
            max: (data.type!.constraints.maxValue) * 1.0,
            divisions: data.type!.constraints.maxValue -
                data.type!.constraints.minValue,
            decoration: InputDecoration(
                label: Text("${AppLocalizations.of(context)!.integerValue}*")),
            autovalidateMode: AutovalidateMode.always,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              if (data.type?.constraints.multipleOf != null)
                (value) {
                  final number = value?.toInt();
                  if (number == null) {
                    return null;
                  }
                  if (number % data.type!.constraints.multipleOf != 0) {
                    return AppLocalizations.of(context)!
                        .multipleOfNum(data.type!.constraints.multipleOf);
                  }
                  return null;
                }
            ]),
          );
  }
}

class IntegerViewer extends StatelessWidget {
  const IntegerViewer({super.key, required this.data});
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
        for (VisibleIntegerInfo stat in data.type?.statsToSee)
          Text(
            "${AppLocalizations.of(context)!.statTerms(stat.name)}: ${data.type?.getStat(context: context, stat: stat)}",
          ),
        data.getHistoric(),
      ],
    );
  }
}
