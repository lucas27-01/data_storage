import 'dart:math';

import 'package:data_storage/extensions/date_extensions.dart';
import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/data_constraints/date_constraints.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:data_storage/widgets/form_builder_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RepresentableDate extends RepresentableDataType {
  RepresentableDate.standard() : super.standard() {
    values = {};
    statsToSee = VisibleDateInfo.values.toSet();
    constraints = DateConstraints.standard();
    customDefaultValue = null;
  }

  RepresentableDate({
    required this.values,
    required this.statsToSee,
    DateConstraints? constraints,
    this.defaultValue = RepresentableDateDefaultValue.none,
    this.customDefaultValue,
  }) : super.standard() {
    this.constraints = constraints ?? DateConstraints.standard();
  }

  factory RepresentableDate.fromJson(Map<String, dynamic> json) {
    return RepresentableDate(
      values: {
        for (var entry in json['values'].entries)
          entry.key: DateTimeExtensions.onlyDatefromJson(entry.value)
      },
      statsToSee: {
        for (var stat in json["statsToSee"]
            .map((name) =>
                VisibleDateInfo.values.firstWhere((el) => el.name == name))
            .toSet())
          stat
      },
      constraints: DateConstraints.fromJson(json["constraints"]),
      defaultValue: RepresentableDateDefaultValue.values
          .firstWhere((test) => test.name == json['defaultValue']),
      customDefaultValue: DateTimeExtensions.onlyDatefromNullableJson(
          json["customDefaultValue"]),
    );
  }

  @override
  late Map<String, DateTime> values;
  @override
  RepresentableDateDefaultValue defaultValue =
      RepresentableDateDefaultValue.none;
  @override
  late DateTime? customDefaultValue;
  @override
  late DateConstraints constraints;
  @override
  late Set<VisibleDateInfo> statsToSee = {};

  @override
  Widget builderWidget({Data? dataToEdit}) {
    return RepresentableDateAdder(dataToEdit: dataToEdit);
  }

  @override
  Type get wantedType => DateTime;

  @override
  String getStat({required BuildContext context, required dynamic stat}) {
    if (stat is VisibleDateInfo) {
      switch (stat) {
        case VisibleDateInfo.totalValuesNum:
          if (values.isNotEmpty) {
            return values.length.toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.dayMean:
          if (values.isNotEmpty) {
            List<int> days = values.values.map((el) => el.day).toList();
            int totalDays = days.reduce((a, b) => a + b);
            return (totalDays / days.length).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.monthMean:
          if (values.isNotEmpty) {
            List<int> months = values.values.map((el) => el.minute).toList();
            int totalMonths = months.reduce((a, b) => a + b);
            return (totalMonths / months.length).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.yearMean:
          if (values.isNotEmpty) {
            List<int> years = values.values.map((el) => el.minute).toList();
            int totalYears = years.reduce((a, b) => a + b);
            return (totalYears / years.length).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.mean:
          if (values.isNotEmpty) {
            return DateTimeExtensions.calculateMean(values.values.toList())
                .formatOnlyDate(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.median:
          if (values.isNotEmpty) {
            List<DateTime> sortedValues = List.from(values.values.toList());
            sortedValues.sort((a, b) {
              return a.secondsSinceEpoch.compareTo(b.secondsSinceEpoch);
            });
            if (sortedValues.length.isOdd) {
              return (sortedValues[sortedValues.length ~/ 2])
                  .formatOnlyDate(context);
            } else {
              int seconds = ((sortedValues[sortedValues.length ~/ 2 - 1]
                              .secondsSinceEpoch +
                          sortedValues[sortedValues.length ~/ 2]
                              .secondsSinceEpoch) /
                      2)
                  .round();
              return DateTimeExtensions.fromSecondsSinceEpoch(seconds)
                  .formatOnlyDate(context);
            }
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.mode:
          if (values.isNotEmpty) {
            Map<DateTime, int> counter = {};
            for (var time in values.values) {
              counter[time] = (counter[time] ?? 0) + 1;
            }
            int maxOccurrences = counter.values.reduce((a, b) => a > b ? a : b);

            String mode = "";
            counter.forEach((time, occurrences) {
              if (occurrences == maxOccurrences) {
                mode += "${time.formatOnlyDate(context)}, ";
              }
            });
            return AppLocalizations.of(context)!.modeWithOccurrences(
                mode.substring(0, mode.length - 2), maxOccurrences);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.minValue:
          if (values.isNotEmpty) {
            return values.values
                .reduce((a, b) => a.isDateSmaller(b) ? a : b)
                .formatOnlyDate(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.maxValue:
          if (values.isNotEmpty) {
            return values.values
                .reduce((a, b) => a.isDateGreater(b) ? a : b)
                .formatOnlyDate(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.standardDeviation:
          if (values.isNotEmpty) {
            num mean = DateTimeExtensions.calculateMean(values.values.toList())
                .secondsSinceEpoch;

            num variance = values.values
                    .map((time) => pow(time.secondsSinceEpoch - mean, 2))
                    .reduce((a, b) => a + b) /
                values.length;
            int standardDeviation = sqrt(variance).round();
            return DateTimeExtensions.fromSecondsSinceEpoch(standardDeviation)
                .formatOnlyDate(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleDateInfo.range:
          if (values.isNotEmpty) {
            int rangeInSeconds = (values.values
                    .reduce((a, b) => a.isDateGreater(b) ? a : b)
                    .secondsSinceEpoch -
                values.values
                    .reduce((a, b) => a.isDateSmaller(b) ? a : b)
                    .secondsSinceEpoch);
            return DateTimeExtensions.fromSecondsSinceEpoch(rangeInSeconds)
                .formatOnlyDate(context);
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
      "_type": "RepresentableDate",
      "values": {
        for (var entry in values.entries)
          entry.key: entry.value.onlyDateToJson()
      },
      "statsToSee": statsToSee.map((el) => el.name).toList(),
      "defaultValue": defaultValue.name,
      "customDefaultValue": customDefaultValue?.onlyDateToJson(),
      "constraints": constraints.toJson(),
    };
  }
}

enum RepresentableDateDefaultValue { none, custom, now }

enum VisibleDateInfo {
  totalValuesNum, // The length of values
  mean, // Mean value
  yearMean, // Only year mean
  monthMean, // Only month mean
  dayMean, // Only day mean
  median, // The center value of the ordered list
  mode, // The most commonly number in the list
  maxValue, // The max Value in the list
  minValue, // The min Value in the list
  standardDeviation, // How much the numbers in the list deviate on average from the mean
  range, // Max value - Min value
}

class RepresentableDateAdder extends StatefulWidget {
  const RepresentableDateAdder({super.key, this.dataToEdit});
  final Data? dataToEdit;

  @override
  State<RepresentableDateAdder> createState() => _RepresentableDateAdderState();
}

class _RepresentableDateAdderState extends State<RepresentableDateAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final Data _newData;
  DateTime? customDefaultValue, maxValue, minValue;
  RepresentableDateDefaultValue defaultValue =
      RepresentableDateDefaultValue.none;
  Set<VisibleDateInfo> statsToSee = {};

  @override
  void initState() {
    _newData =
        widget.dataToEdit ?? Data(name: "", type: RepresentableDate.standard());
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
                        .questionDeleteAddingDateType),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.dateDataAdding),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormBuilder(
            autovalidateMode: AutovalidateMode.onUnfocus,
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
                  FormBuilderChoiceChip<RepresentableDateDefaultValue>(
                    spacing: 8,
                    initialValue: _newData.type?.defaultValue ??
                        RepresentableDateDefaultValue.none,
                    validator: FormBuilderValidators.aggregate([
                      FormBuilderValidators.required(),
                      (value) {
                        if (maxValue != null && customDefaultValue != null) {
                          return customDefaultValue!.isDateGreater(maxValue!)
                              ? AppLocalizations.of(context)!.dateSmallerEqual(
                                  maxValue!.formatOnlyDate(context))
                              : null;
                        }
                        return null;
                      },
                      (value) {
                        if (minValue != null && customDefaultValue != null) {
                          return customDefaultValue!.isDateSmaller(minValue!)
                              ? AppLocalizations.of(context)!.dateGreaterEqual(
                                  minValue!.formatOnlyDate(context))
                              : null;
                        }
                        return null;
                      },
                    ]),
                    name: 'defaultValue',
                    onChanged: (newValue) async {
                      switch (newValue) {
                        case RepresentableDateDefaultValue.none:
                        case RepresentableDateDefaultValue.now:
                          defaultValue = newValue!;
                          customDefaultValue = null;
                          break;
                        case RepresentableDateDefaultValue.custom:
                          defaultValue = RepresentableDateDefaultValue.custom;
                          customDefaultValue = await showDatePicker(
                              context: context,
                              initialDate: customDefaultValue ??
                                  minValue ??
                                  maxValue ??
                                  DateTime.now().onlyDate(),
                              firstDate: minValue ?? DateTime(0),
                              lastDate: maxValue ?? DateTime(7000, 12, 31));

                          if (customDefaultValue == null) {
                            _formKey.currentState?.fields['defaultValue']
                                ?.didChange(RepresentableDateDefaultValue.none);
                          }
                          break;
                        default:
                          defaultValue = RepresentableDateDefaultValue.none;
                          setState(() {
                            _formKey.currentState?.fields['defaultValue']
                                ?.didChange(RepresentableDateDefaultValue.none);
                          });
                          break;
                      }
                      setState(() {});
                    },
                    options: [
                      FormBuilderChipOption(
                        value: RepresentableDateDefaultValue.none,
                        child:
                            Text(AppLocalizations.of(context)!.noDefaultValue),
                      ),
                      FormBuilderChipOption(
                        value: RepresentableDateDefaultValue.now,
                        child: Text(
                            AppLocalizations.of(context)!.dateOfValueAdding),
                      ),
                      FormBuilderChipOption(
                          value: RepresentableDateDefaultValue.custom,
                          child: Text(AppLocalizations.of(context)!
                              .selectedDate(
                                  customDefaultValue?.formatOnlyDate(context) ??
                                      'void')))
                    ],
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.defaultValue),
                    ),
                  ),
                  FormBuilderCheckboxGroup(
                    name: "statsToSee",
                    options: [
                      for (var info in VisibleDateInfo.values)
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
                                                .explainDateStatsToSee)),
                                  ),
                                ),
                            icon: const Icon(Icons.help_outline_rounded))),
                  ),
                  Text(
                    AppLocalizations.of(context)!.constraintsSettings,
                    style: const TextStyle(fontSize: 24),
                  ),
                  FormBuilderSwitch(
                    name: 'isRequired',
                    initialValue: _newData.type?.constraints.isRequired ?? true,
                    title: Text(
                      AppLocalizations.of(context)!.isRequired,
                      style: const TextStyle(fontSize: 16),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  FormBuilderChoiceChip<bool>(
                      spacing: 8,
                      name: 'minValue',
                      initialValue: _newData.type?.constraints.minValue != null,
                      onChanged: (hasMinValue) async {
                        switch (hasMinValue) {
                          case true:
                            minValue = await showDatePicker(
                                context: context,
                                initialDate: minValue ??
                                    maxValue ??
                                    DateTime.now().onlyDate(),
                                firstDate: DateTime(0),
                                lastDate: maxValue ?? DateTime(7000, 12, 31));

                            if (minValue == null) {
                              _formKey.currentState?.fields['minValue']
                                  ?.didChange(false);
                            }
                            break;
                          default:
                            minValue = null;
                        }
                        setState(() {});
                      },
                      options: [
                        FormBuilderChipOption(
                          value: false,
                          child: Text(AppLocalizations.of(context)!.noMinDate),
                        ),
                        FormBuilderChipOption(
                          value: true,
                          child: Text(AppLocalizations.of(context)!
                              .selectedDate(
                                  minValue?.formatOnlyDate(context) ?? "void")),
                        )
                      ],
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.minValue),
                      ),
                      validator: (value) {
                        if (maxValue != null && minValue != null) {
                          return minValue!.isDateGreater(maxValue!)
                              ? AppLocalizations.of(context)!.dateSmallerEqual(
                                  maxValue!.formatOnlyDate(context))
                              : null;
                        }
                        return null;
                      }),
                  FormBuilderChoiceChip<bool>(
                    spacing: 8,
                    name: 'maxValue',
                    initialValue: _newData.type?.constraints.maxValue != null,
                    onChanged: (hasMaxValue) async {
                      switch (hasMaxValue) {
                        case true:
                          maxValue = await showDatePicker(
                              context: context,
                              initialDate: maxValue ??
                                  minValue ??
                                  DateTime.now().onlyDate(),
                              firstDate: minValue ?? DateTime(0),
                              lastDate: DateTime(7000, 12, 31));
                          if (maxValue == null) {
                            _formKey.currentState?.fields['maxValue']
                                ?.didChange(false);
                          }
                          break;
                        default:
                          maxValue = null;
                          break;
                      }
                      setState(() {});
                    },
                    options: [
                      FormBuilderChipOption(
                        value: false,
                        child: Text(AppLocalizations.of(context)!.noMaxDate),
                      ),
                      FormBuilderChipOption(
                        value: true,
                        child: Text(AppLocalizations.of(context)!.selectedDate(
                            maxValue?.formatOnlyDate(context) ?? "void")),
                      )
                    ],
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.maxValue),
                    ),
                    validator: (value) {
                      if (minValue != null && maxValue != null) {
                        return maxValue!.isDateSmaller(minValue!)
                            ? AppLocalizations.of(context)!.dateGreaterEqual(
                                maxValue!.formatOnlyDate(context))
                            : null;
                      }
                      return null;
                    },
                  ),
                  FormBuilderChoiceChip<bool?>(
                    spacing: 8,
                    name: 'hasToBeFuture',
                    options: [
                      FormBuilderChipOption(
                        value: null,
                        child: Text(
                            AppLocalizations.of(context)!.noDateConstraints),
                      ),
                      FormBuilderChipOption(
                        value: true,
                        child:
                            Text(AppLocalizations.of(context)!.hasToBeFuture),
                      ),
                      FormBuilderChipOption(
                        value: false,
                        child: Text(AppLocalizations.of(context)!.hasToBePast),
                      ),
                    ],
                    decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!
                            .explainDateConstraints)),
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
                      print(_formKey.currentState?.value["isRequired"]);
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        _newData.type = RepresentableDate(
                          values:
                              _newData.type?.values as Map<String, DateTime>? ??
                                  {},
                          statsToSee: statsToSee,
                          defaultValue: defaultValue,
                          customDefaultValue: customDefaultValue,
                          constraints: DateConstraints(
                            isRequired:
                                _formKey.currentState?.value["isRequired"] ??
                                    true,
                            maxValue: maxValue,
                            minValue: minValue,
                            hasToBeFuture:
                                _formKey.currentState?.value['hasToBeFuture'],
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

class DateHistoric extends StatelessWidget {
  const DateHistoric({super.key, required this.data});
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
                (entry.value as DateTime).formatOnlyDate(context),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  DateTimeExtensions.fromSecondsSinceEpoch(int.parse(entry.key))
                      .formatDateTimeLocalized(context)),
            ),
          const Divider()
        ],
      ),
    );
  }
}

class DateValueAdder extends StatelessWidget {
  DateValueAdder({super.key, required this.data, this.initialValue})
      : isRequired = data.type?.constraints.isRequired ?? true;
  final Data data;
  final DateTime? initialValue;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    print(data.type?.constraints.isRequired);
    return FormBuilderDate(
      name: data.name,
      firstDate: data.type?.constraints.minValue ?? DateTime(0),
      lastDate: data.type?.constraints.maxValue ?? DateTime(7000, 12, 31),
      initialValue: initialValue ??
          {
            RepresentableDateDefaultValue.none: null,
            null: null,
            RepresentableDateDefaultValue.now: DateTime.now(),
            RepresentableDateDefaultValue.custom: data.type?.customDefaultValue
          }[data.type?.defaultValue],
      decoration: InputDecoration(
          label: Text("${AppLocalizations.of(context)!.date}*")),
      validator: FormBuilderValidators.aggregate(
        [
          if (isRequired)
            FormBuilderValidators.required(
              checkNullOrEmpty: isRequired,
            ),
          (newValue) {
            if (data.type?.constraints.minValue != null && newValue != null) {
              return newValue.isDateSmaller(data.type!.constraints.minValue)
                  ? AppLocalizations.of(context)!.dateGreaterEqual(
                      data.type!.constraints.minValue!.format(context))
                  : null;
            }
            return null;
          },
          (newValue) {
            if (data.type?.constraints.maxValue != null && newValue != null) {
              return newValue.isDateGreater(data.type!.constraints.maxValue)
                  ? AppLocalizations.of(context)!.dateSmallerEqual(
                      data.type!.constraints.maxValue!.format(context))
                  : null;
            }
            return null;
          },
          (newValue) {
            if (newValue != null) {
              switch (data.type?.constraints.hasToBeFuture) {
                case true:
                  return newValue.isDateSmaller(DateTime.now().onlyDate())
                      ? AppLocalizations.of(context)!.dateHasToBeFuture
                      : null;
                case false:
                  return newValue.isDateGreater(DateTime.now().onlyDate())
                      ? AppLocalizations.of(context)!.dateHasToBePast
                      : null;
              }
            }
            return null;
          }
        ],
      ),
    );
  }
}

class DateViewer extends StatelessWidget {
  const DateViewer({super.key, required this.data});
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
        for (VisibleDateInfo stat in data.type?.statsToSee)
          Text(
            "${AppLocalizations.of(context)!.statTerms(stat.name)}: ${data.type?.getStat(context: context, stat: stat)}",
          ),
        data.getHistoric(),
      ],
    );
  }
}
