import 'dart:math';

import 'package:data_storage/extensions/date_extensions.dart';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/data_constraints/decimal_constraints.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RepresentableDecimal extends RepresentableDataType {
  RepresentableDecimal.standard() : super.standard() {
    values = {};
    defaultValue = null;
    constraints = DecimalConstraints.standard();
    statsToSee = VisibleDecimalInfo.values.toSet();
  }

  RepresentableDecimal({
    required this.values,
    required this.statsToSee,
    this.defaultValue,
    DecimalConstraints? constraints,
  }) : super.standard() {
    this.constraints = constraints ?? DecimalConstraints.standard();
  }

  factory RepresentableDecimal.fromJson(Map<String, dynamic> json) {
    return RepresentableDecimal(
      values: {
        for (var entry in json["values"].entries) entry.key: entry.value
      },
      statsToSee: {
        for (var stat in json["statsToSee"]
            .map((name) =>
                VisibleDecimalInfo.values.firstWhere((el) => el.name == name))
            .toSet())
          stat
      },
      defaultValue: json["defaultValue"],
      constraints: DecimalConstraints.fromJson(json["constraints"]),
    );
  }

  @override
  late Map<String, num> values;
  @override
  late num? defaultValue;
  @override
  late DecimalConstraints constraints;
  @override
  late Set<VisibleDecimalInfo> statsToSee = {};

  @override
  Type get wantedType => num;

  @override
  Widget builderWidget({Data? dataToEdit}) {
    return RepresentableDecimalAdder(
      dataToEdit: dataToEdit,
    );
  }

  @override
  String getStat({required BuildContext context, required dynamic stat}) {
    if (stat is VisibleDecimalInfo) {
      switch (stat) {
        case VisibleDecimalInfo.totalValuesNum:
          return values.length.toString();
        case VisibleDecimalInfo.mean:
          if (values.isNotEmpty) {
            return (values.values.reduce((a, b) => a + b) / values.length)
                .toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDecimalInfo.totalSum:
          if (values.isNotEmpty) {
            return values.values.reduce((a, b) => a + b).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDecimalInfo.median:
          if (values.isNotEmpty) {
            List<num> sortedValues = List.from(values.values.toList());
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
        case VisibleDecimalInfo.mode:
          if (values.isNotEmpty) {
            Map<num, int> counter = {};
            for (var number in values.values) {
              counter[number] = (counter[number] ?? 0) + 1;
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
        case VisibleDecimalInfo.minValue:
          if (values.isNotEmpty) {
            return values.values.reduce((a, b) => a < b ? a : b).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDecimalInfo.maxValue:
          if (values.isNotEmpty) {
            return values.values.reduce((a, b) => a > b ? a : b).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDecimalInfo.standardDeviation:
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
        case VisibleDecimalInfo.range:
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
      "_type": "RepresentableDecimal",
      "values": values,
      "statsToSee": statsToSee.map((el) => el.name).toList(),
      "defaultValue": defaultValue,
      "constraints": constraints.toJson(),
    };
  }
}

enum VisibleDecimalInfo {
  totalValuesNum, // The number of valus
  totalSum, // Sum of each value
  mean, // Mean value
  median, // The center value of the ordered list
  mode, // The most commonly number in the list
  maxValue, // The max Value in the list
  minValue, // The min Value in the list
  standardDeviation, // How much the numbers in the list deviate on average from the mean
  range // Max value - Min value
}

class RepresentableDecimalAdder extends StatefulWidget {
  const RepresentableDecimalAdder({super.key, this.dataToEdit});
  final Data? dataToEdit;

  @override
  State<RepresentableDecimalAdder> createState() =>
      _RepresentableDecimalAdderState();
}

class _RepresentableDecimalAdderState extends State<RepresentableDecimalAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final Data _newData;
  num? defaultValue, maxValue, minValue, multipleOf;
  late Set<VisibleDecimalInfo> statsToSee = {};

  @override
  void initState() {
    _newData = widget.dataToEdit ??
        Data(name: "", type: RepresentableDecimal.standard());
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
                        .questionDeleteAddingDecimalType),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.decimalDataAdding),
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
                    maxLength: 300,
                    validator: FormBuilderValidators.maxLength(
                      300,
                      checkNullOrEmpty: false,
                    ),
                  ),
                  FormBuilderTextField(
                    initialValue:
                        (_newData.type?.defaultValue ?? "").toString(),
                    name: 'defaultValue',
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.defaultValue),
                      hintText: AppLocalizations.of(context)!.dataDefaultValue,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.numeric(checkNullOrEmpty: false),
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
                      for (var info in VisibleDecimalInfo.values)
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
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.minValue),
                      hintText: AppLocalizations.of(context)!.dataDefaultValue,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.numeric(checkNullOrEmpty: false),
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
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.maxValue),
                      hintText: AppLocalizations.of(context)!.dataMaxValue,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.numeric(checkNullOrEmpty: false),
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
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.multipleOf),
                      hintText: AppLocalizations.of(context)!.valueMultipleOf,
                    ),
                    validator: FormBuilderValidators.compose(
                      [FormBuilderValidators.numeric(checkNullOrEmpty: false)],
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
                        defaultValue = double.parse(
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
                            num.parse(_formKey.currentState?.value["maxValue"]);
                      } catch (_) {
                        maxValue = null;
                      }

                      try {
                        minValue =
                            num.parse(_formKey.currentState?.value["minValue"]);
                      } catch (_) {
                        minValue = null;
                      }

                      try {
                        multipleOf = num.parse(
                            _formKey.currentState?.value["multipleOf"]);
                      } catch (e) {
                        multipleOf = null;
                      }

                      setState(() {});
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        _newData.type = RepresentableDecimal(
                          values:
                              _newData.type?.values as Map<String, num>? ?? {},
                          statsToSee: statsToSee,
                          defaultValue: defaultValue,
                          constraints: DecimalConstraints(
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

class DecimalHistoric extends StatelessWidget {
  const DecimalHistoric({super.key, required this.data});
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

class DecimalValueAdder extends StatelessWidget {
  const DecimalValueAdder({super.key, required this.data, this.initialValue});
  final Data data;
  final num? initialValue;

  @override
  Widget build(BuildContext context) {
    return data.type?.constraints.maxValue == null ||
            data.type?.constraints.minValue == null
        ? FormBuilderTextField(
            name: data.name,
            initialValue: initialValue?.toString() ??
                (data.type?.defaultValue ?? "").toString(),
            autovalidateMode: AutovalidateMode.onUnfocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                label: Text("${AppLocalizations.of(context)!.decimalValue}*"),
                hintText: AppLocalizations.of(context)!.decimalValue),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.numeric(),
              FormBuilderValidators.required(),
              if (data.type?.constraints.maxValue != null)
                FormBuilderValidators.max(data.type!.constraints.maxValue),
              if (data.type?.constraints.minValue != null)
                FormBuilderValidators.min(data.type!.constraints.minValue),
              if (data.type?.constraints.multipleOf != null)
                (value) {
                  final number = num.tryParse(value!);
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
            initialValue: initialValue ??
                data.type?.defaultValue ??
                data.type!.constraints.minValue,
            min: data.type!.constraints.minValue.toDouble(),
            max: data.type!.constraints.maxValue.toDouble(),
            divisions: data.type?.constraints.multipleOf != null
                ? ((data.type?.constraints.maxValue -
                            data.type?.constraints.minValue) /
                        data.type?.constraints.multipleOf)
                    .round()
                : null,
            decoration: InputDecoration(
                label: Text("${AppLocalizations.of(context)!.decimalValue}*")),
            autovalidateMode: AutovalidateMode.always,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              if (data.type?.constraints.multipleOf != null)
                (value) {
                  final number = value!;
                  if (number % data.type!.constraints.multipleOf != 0) {
                    return AppLocalizations.of(context)!
                        .multipleOfNum(data.type?.constraints.multipleOf);
                  }
                  return null;
                }
            ]),
          );
  }
}

class DecimalViewer extends StatelessWidget {
  const DecimalViewer({super.key, required this.data});
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
        for (VisibleDecimalInfo stat in data.type?.statsToSee)
          Text(
            "${AppLocalizations.of(context)!.statTerms(stat.name)}: ${data.type?.getStat(context: context, stat: stat)}",
          ),
        data.getHistoric(),
      ],
    );
  }
}
