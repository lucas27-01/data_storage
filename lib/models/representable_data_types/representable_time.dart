import 'dart:math';

import 'package:data_storage/models/data_constraints/time_constraints.dart';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:data_storage/widgets/form_builder_time_of_day.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:data_storage/extensions/date_extensions.dart';

class RepresentableTime extends RepresentableDataType {
  RepresentableTime.standard() : super.standard() {
    values = {};
    defaultValue = RepresentableTimeDefaultValue.none;
    customDefaultValue = null;
    constraints = TimeConstraints.standard();
    statsToSee.addAll(VisibleTimeInfo.values);
  }

  RepresentableTime({
    required this.values,
    required this.statsToSee,
    this.defaultValue = RepresentableTimeDefaultValue.none,
    this.customDefaultValue,
    TimeConstraints? constraints,
  }) : super.standard() {
    this.constraints = constraints ?? TimeConstraints.standard();
  }

  factory RepresentableTime.fromJson(Map<String, dynamic> json) {
    return RepresentableTime(
      values: {
        for (var entry in json["values"].entries)
          entry.key: TimeOfDayExtension.fromJson(entry.value)
      },
      statsToSee: {
        for (var stat in json["statsToSee"]
            .map((name) =>
                VisibleTimeInfo.values.firstWhere((el) => el.name == name))
            .toSet())
          stat
      },
      defaultValue: RepresentableTimeDefaultValue.values
          .firstWhere((el) => el.name == json['defaultValue']),
      customDefaultValue:
          TimeOfDayExtension.fromNullableJson(json['customDefaultValue']),
      constraints: TimeConstraints.fromJson(json["constraints"]),
    );
  }

  @override
  late Map<String, TimeOfDay> values;
  @override
  late RepresentableTimeDefaultValue defaultValue;
  @override
  late TimeOfDay? customDefaultValue;
  @override
  late TimeConstraints constraints;
  @override
  late Set<VisibleTimeInfo> statsToSee = {};

  @override
  Widget builderWidget({Data? dataToEdit}) {
    return RepresentableTimeAdder(
      dataToEdit: dataToEdit,
    );
  }

  @override
  Type get wantedType => TimeOfDay;

  @override
  String getStat({required BuildContext context, required dynamic stat}) {
    if (stat is VisibleTimeInfo) {
      switch (stat) {
        case VisibleTimeInfo.totalValuesNum:
          if (values.isNotEmpty) {
            return values.length.toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.hourMean:
          if (values.isNotEmpty) {
            List<int> hours = values.values.map((el) => el.hour).toList();
            int totalHours = hours.reduce((a, b) => a + b);
            return (totalHours / hours.length).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.minuteMean:
          if (values.isNotEmpty) {
            List<int> minutes = values.values.map((el) => el.minute).toList();
            int totalMinutes = minutes.reduce((a, b) => a + b);
            return (totalMinutes / minutes.length).toString();
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.mean:
          if (values.isNotEmpty) {
            return TimeOfDayExtension.calulateMean(values.values.toList())
                .format(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.median:
          if (values.isNotEmpty) {
            List<TimeOfDay> sortedValues = List.from(values.values.toList());
            sortedValues.sort((a, b) {
              int aMinutes = a.hour * 60 + a.minute;
              int bMinutes = b.hour * 60 + b.minute;
              return aMinutes.compareTo(bMinutes);
            });
            if (sortedValues.length.isOdd) {
              return (sortedValues[sortedValues.length ~/ 2]).format(context);
            } else {
              int minute = ((sortedValues[sortedValues.length ~/ 2 - 1]
                              .toMinute() +
                          sortedValues[sortedValues.length ~/ 2].toMinute()) /
                      2)
                  .round();
              return TimeOfDay(hour: minute ~/ 60, minute: minute % 60)
                  .format(context);
            }
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.mode:
          if (values.isNotEmpty) {
            Map<TimeOfDay, int> counter = {};
            for (var time in values.values) {
              counter[time] = (counter[time] ?? 0) + 1;
            }
            int maxOccurrences = counter.values.reduce((a, b) => a > b ? a : b);

            String mode = "";
            counter.forEach((time, occurrences) {
              if (occurrences == maxOccurrences) {
                mode += "${time.format(context)}, ";
              }
            });
            return AppLocalizations.of(context)!.modeWithOccurrences(
                mode.substring(0, mode.length - 2), maxOccurrences);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.minValue:
          if (values.isNotEmpty) {
            return values.values
                .reduce((a, b) => a < b ? a : b)
                .format(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.maxValue:
          if (values.isNotEmpty) {
            return values.values
                .reduce((a, b) => a > b ? a : b)
                .format(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.standardDeviation:
          if (values.isNotEmpty) {
            num mean = TimeOfDayExtension.calulateMean(values.values.toList())
                .toMinute();

            num variance = values.values
                    .map((time) => pow(time.toMinute() - mean, 2))
                    .reduce((a, b) => a + b) /
                values.length;
            int standardDeviation = sqrt(variance).round();
            return TimeOfDay(
                    hour: standardDeviation ~/ 60,
                    minute: standardDeviation % 60)
                .format(context);
          } else {
            return AppLocalizations.of(context)!.noData;
          }
        case VisibleTimeInfo.range:
          if (values.isNotEmpty) {
            int rangeInMinute =
                (values.values.reduce((a, b) => a > b ? a : b).toMinute() -
                    values.values.reduce((a, b) => a < b ? a : b).toMinute());
            return TimeOfDay(
                    hour: rangeInMinute ~/ 60, minute: rangeInMinute % 60)
                .format(context);
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
      "_type": "RepresentableTime",
      "values": {
        for (var value in values.entries) value.key: value.value.toJson()
      },
      "statsToSee": statsToSee.map((el) => el.name).toList(),
      "defaultValue": defaultValue.name,
      "customDefaultValue": customDefaultValue?.toJson(),
      "constraints": constraints.toJson(),
    };
  }
}

enum RepresentableTimeDefaultValue { none, custom, now }

enum VisibleTimeInfo {
  totalValuesNum, // The length of values
  mean, // Mean value
  hourMean, // Only hours mean
  minuteMean, // Only minute mean
  median, // The center value of the ordered list
  mode, // The most commonly number in the list
  maxValue, // The max Value in the list
  minValue, // The min Value in the list
  standardDeviation, // How much the numbers in the list deviate on average from the mean
  range, // Max value - Min value
}

class RepresentableTimeAdder extends StatefulWidget {
  const RepresentableTimeAdder({super.key, this.dataToEdit});
  final Data? dataToEdit;

  @override
  State<RepresentableTimeAdder> createState() => _RepresentableTimeAdderState();
}

class _RepresentableTimeAdderState extends State<RepresentableTimeAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final Data _newData;
  TimeOfDay? customDefaultValue, maxValue, minValue;
  RepresentableTimeDefaultValue defaultValue =
      RepresentableTimeDefaultValue.none;
  Set<VisibleTimeInfo> statsToSee = {};

  @override
  void initState() {
    _newData =
        widget.dataToEdit ?? Data(name: "", type: RepresentableTime.standard());
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
                        .questionDeleteAddingTimeType),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.timeDataAdding),
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
                    maxLength: 50,
                    validator: FormBuilderValidators.maxLength(
                      50,
                      checkNullOrEmpty: false,
                    ),
                  ),
                  FormBuilderChoiceChip<RepresentableTimeDefaultValue>(
                    spacing: 8,
                    initialValue: _newData.type?.defaultValue ??
                        RepresentableTimeDefaultValue.none,
                    validator: FormBuilderValidators.aggregate([
                      FormBuilderValidators.required(),
                      (value) {
                        if (maxValue != null && customDefaultValue != null) {
                          return customDefaultValue! > maxValue!
                              ? AppLocalizations.of(context)!
                                  .timeSmallerEqual(maxValue!.format(context))
                              : null;
                        }
                        return null;
                      },
                      (value) {
                        if (minValue != null && customDefaultValue != null) {
                          return customDefaultValue! < minValue!
                              ? AppLocalizations.of(context)!
                                  .timeGreaterEqual(minValue!.format(context))
                              : null;
                        }
                        return null;
                      },
                    ]),
                    name: 'defaultValue',
                    onChanged: (newValue) async {
                      switch (newValue) {
                        case RepresentableTimeDefaultValue.none:
                        case RepresentableTimeDefaultValue.now:
                          defaultValue = newValue!;
                          customDefaultValue = null;
                          break;
                        case RepresentableTimeDefaultValue.custom:
                          defaultValue = RepresentableTimeDefaultValue.custom;
                          customDefaultValue = await showTimePicker(
                            context: context,
                            initialTime: customDefaultValue ?? TimeOfDay.now(),
                          );

                          if (customDefaultValue == null) {
                            _formKey.currentState?.fields['defaultValue']
                                ?.didChange(RepresentableTimeDefaultValue.none);
                          }
                          break;
                        default:
                          defaultValue = RepresentableTimeDefaultValue.none;
                          setState(() {
                            _formKey.currentState?.fields['defaultValue']
                                ?.didChange(RepresentableTimeDefaultValue.none);
                          });
                          break;
                      }
                      setState(() {});
                    },
                    options: [
                      FormBuilderChipOption(
                        value: RepresentableTimeDefaultValue.none,
                        child:
                            Text(AppLocalizations.of(context)!.noDefaultValue),
                      ),
                      FormBuilderChipOption(
                        value: RepresentableTimeDefaultValue.now,
                        child: Text(
                            AppLocalizations.of(context)!.timeOfValueAdding),
                      ),
                      FormBuilderChipOption(
                          value: RepresentableTimeDefaultValue.custom,
                          child: Text(AppLocalizations.of(context)!
                              .selectedTime(
                                  customDefaultValue?.format(context) ??
                                      'void')))
                    ],
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.defaultValue),
                    ),
                  ),
                  FormBuilderCheckboxGroup(
                    name: "statsToSee",
                    options: [
                      for (var info in VisibleTimeInfo.values)
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
                                                .explainTimeStatsToSee)),
                                  ),
                                ),
                            icon: const Icon(Icons.help_outline_rounded))),
                  ),
                  Text(
                    AppLocalizations.of(context)!.constraintsSettings,
                    style: const TextStyle(fontSize: 24),
                  ),
                  FormBuilderChoiceChip<bool>(
                      spacing: 8,
                      name: 'minValue',
                      initialValue: _newData.type?.constraints.minValue != null,
                      onChanged: (hasMinValue) async {
                        switch (hasMinValue) {
                          case true:
                            minValue = await showTimePicker(
                              context: context,
                              initialTime:
                                  minValue ?? maxValue ?? TimeOfDay.now(),
                            );

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
                          child: Text(AppLocalizations.of(context)!.noMinTime),
                        ),
                        FormBuilderChipOption(
                          value: true,
                          child: Text(AppLocalizations.of(context)!
                              .selectedTime(
                                  minValue?.format(context) ?? "void")),
                        )
                      ],
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.minValue),
                      ),
                      validator: (value) {
                        if (maxValue != null && minValue != null) {
                          return minValue! > maxValue!
                              ? AppLocalizations.of(context)!
                                  .timeSmallerEqual(maxValue!.format(context))
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
                          maxValue = await showTimePicker(
                            context: context,
                            initialTime:
                                maxValue ?? minValue ?? TimeOfDay.now(),
                          );
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
                        child: Text(AppLocalizations.of(context)!.noMaxTime),
                      ),
                      FormBuilderChipOption(
                        value: true,
                        child: Text(AppLocalizations.of(context)!
                            .selectedTime(maxValue?.format(context) ?? "void")),
                      )
                    ],
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.maxValue),
                    ),
                    validator: (value) {
                      if (minValue != null && maxValue != null) {
                        return maxValue! < minValue!
                            ? AppLocalizations.of(context)!
                                .timeGreaterEqual(maxValue!.format(context))
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
                            AppLocalizations.of(context)!.noTimeConstraints),
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
                            .explainTimeConstraints)),
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
                        _newData.type = RepresentableTime(
                          values: _newData.type?.values
                                  as Map<String, TimeOfDay>? ??
                              {},
                          statsToSee: statsToSee,
                          defaultValue: defaultValue,
                          customDefaultValue: customDefaultValue,
                          constraints: TimeConstraints(
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

class TimeHistoric extends StatelessWidget {
  const TimeHistoric({super.key, required this.data});
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
                entry.value.format(context),
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

class TimeValueAdder extends StatelessWidget {
  const TimeValueAdder({super.key, required this.data, this.initialValue});
  final Data data;
  final TimeOfDay? initialValue;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTimeOfDay(
      name: data.name,
      initialValue: initialValue ??
          {
            RepresentableTimeDefaultValue.none: null,
            null: null,
            RepresentableTimeDefaultValue.now: TimeOfDay.now(),
            RepresentableTimeDefaultValue.custom: data.type?.customDefaultValue
          }[data.type?.defaultValue],
      decoration: InputDecoration(
          label: Text("${AppLocalizations.of(context)!.time}*")),
      validator: FormBuilderValidators.aggregate(
        [
          FormBuilderValidators.required(),
          (newValue) {
            if (data.type?.constraints.minValue != null && newValue != null) {
              return newValue < data.type!.constraints.minValue
                  ? AppLocalizations.of(context)!.timeGreaterEqual(
                      data.type!.constraints.minValue!.format(context))
                  : null;
            }
            return null;
          },
          (newValue) {
            if (data.type?.constraints.maxValue != null && newValue != null) {
              return newValue > data.type!.constraints.maxValue
                  ? AppLocalizations.of(context)!.timeSmallerEqual(
                      data.type!.constraints.maxValue!.format(context))
                  : null;
            }
            return null;
          },
          (newValue) {
            if (newValue != null) {
              switch (data.type?.constraints.hasToBeFuture) {
                case true:
                  return newValue < TimeOfDay.now()
                      ? AppLocalizations.of(context)!.timeHasToBeFuture
                      : null;
                case false:
                  return newValue > TimeOfDay.now()
                      ? AppLocalizations.of(context)!.timeHasToBePast
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

class TimeViewer extends StatelessWidget {
  const TimeViewer({super.key, required this.data});
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
        for (VisibleTimeInfo stat in data.type?.statsToSee)
          Text(
            "${AppLocalizations.of(context)!.statTerms(stat.name)}: ${data.type?.getStat(context: context, stat: stat)}",
          ),
        data.getHistoric(),
      ],
    );
  }
}
