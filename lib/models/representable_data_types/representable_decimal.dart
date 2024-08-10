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
  }

  RepresentableDecimal({
    required this.values,
    this.defaultValue,
    DecimalConstraints? constraints,
  }) : super.standard() {
    this.constraints = constraints ?? DecimalConstraints.standard();
  }

  factory RepresentableDecimal.fromJson(Map<String, dynamic> json) {
    return RepresentableDecimal(
      values: json["values"],
      defaultValue: json["defaultValue"],
      constraints: DecimalConstraints.fromJson(json["constraints"]),
    );
  }

  late Map<String, double> values;
  @override
  late num? defaultValue;
  @override
  late DecimalConstraints constraints;

  Widget get builderWidget => const RepresentableDecimalAdder();

  @override
  Map<String, dynamic> toJson() {
    return {
      "_type": "RepresentableDecimal",
      "values": values,
      "defaultValue": defaultValue,
      "constraints": constraints.toJson(),
    };
  }
}

class RepresentableDecimalAdder extends StatefulWidget {
  const RepresentableDecimalAdder({super.key});

  @override
  State<RepresentableDecimalAdder> createState() =>
      _RepresentableDecimalAdderState();
}

class _RepresentableDecimalAdderState extends State<RepresentableDecimalAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _newData = Data(name: "", type: RepresentableDecimal.standard());
  num? defaultValue, maxValue, minValue, multipleOf;

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
                  Text(
                    AppLocalizations.of(context)!.constraintsSettings,
                    style: const TextStyle(fontSize: 24),
                  ),
                  FormBuilderTextField(
                    initialValue:
                        (_newData.type?.constraints.minValue ?? "").toString(),
                    name: 'minValue',
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
                            _formKey.currentState?.value["deafultValue"]);
                      } catch (_) {
                        defaultValue = null;
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
                          values: {},
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
