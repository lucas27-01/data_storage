import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormBuilderTimeOfDay extends FormBuilderField<TimeOfDay> {
  FormBuilderTimeOfDay({
    super.key,
    required super.name,
    super.validator,
    InputDecoration decoration = const InputDecoration(),
    super.initialValue,
    super.enabled,
  }) : super(
          builder: (field) => InputDecorator(
            decoration: decoration.copyWith(errorText: field.errorText),
            child: ListTile(
              title: Text(
                AppLocalizations.of(field.context)!.addingSelectedTime(
                    field.value?.format(field.context) ?? 'void'),
              ),
              trailing: const Icon(Icons.access_time_rounded),
              onTap: () async {
                final time = await showTimePicker(
                    context: field.context,
                    initialTime: field.value ?? TimeOfDay.now());
                if (time != null) {
                  field.didChange(time);
                }
              },
            ),
          ),
        );
}
