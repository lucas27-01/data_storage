import 'package:data_storage/extensions/date_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormBuilderDate extends FormBuilderField<DateTime?> {
  FormBuilderDate({
    super.key,
    required super.name,
    required DateTime firstDate,
    required DateTime lastDate,
    super.validator,
    InputDecoration decoration = const InputDecoration(),
    super.initialValue,
    super.enabled,
  }) : super(
          builder: (field) => InputDecorator(
            decoration: decoration.copyWith(errorText: field.errorText),
            child: ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(
                AppLocalizations.of(field.context)!.addingSelectedTime(
                    field.value?.formatOnlyDate(field.context) ?? 'void'),
              ),
              trailing: IconButton(
                  onPressed: () => field.didChange(null),
                  icon: const Icon(CupertinoIcons.trash_fill)),
              onTap: () async {
                final time = await showDatePicker(
                  context: field.context,
                  initialDate: field.value ?? DateTime.now(),
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                // if (time != null) {
                field.didChange(time);
                // }
              },
            ),
          ),
        );
}
