// Default Value is not included
import 'package:data_storage/models/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DataPreferencies extends StatelessWidget {
  const DataPreferencies({super.key, required Data newData}) : _newData = newData;
  final Data _newData;

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}
