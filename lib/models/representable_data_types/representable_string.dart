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
  }

  RepresentableString({
    required this.values,
    this.defaultValue,
    StringConstraints? constraints,
  }) : super.standard() {
    this.constraints = constraints ?? StringConstraints.standard();
  }

  factory RepresentableString.fromJson(Map<String, dynamic> json) {
    return RepresentableString(
      values: json["values"],
      defaultValue: json["defaultValue"],
      constraints: StringConstraints.fromJson(json["constraints"]),
    );
  }

  late Map<String, String>
      values; // Secs from Unix Epoch that represents value added and the value
  @override
  late String? defaultValue;
  @override
  late StringConstraints constraints;

  Widget get builderWidget => const RepresentableStringAdder();

  @override
  Map<String, dynamic> toJson() {
    return {
      "_type": "RepresentableString",
      "values": values,
      "defaultValue": defaultValue,
      "constraints": constraints.toJson(),
    };
  }
}

class RepresentableStringAdder extends StatefulWidget {
  const RepresentableStringAdder({super.key});

  @override
  State<RepresentableStringAdder> createState() =>
      _RepresentableStringAdderState();
}

class _RepresentableStringAdderState extends State<RepresentableStringAdder> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _newData = Data(name: "", type: RepresentableString.standard());
  String? defaultValue;
  int? minLength, maxLength, maxWordsCount, minWordsCount;
  bool onlyAlphabetical = false;

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
                            _formKey.currentState?.value["deafultValue"];
                      } catch (_) {
                        defaultValue = null;
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
                          values: {},
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
