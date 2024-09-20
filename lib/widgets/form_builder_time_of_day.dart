import 'package:data_storage/widgets/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormBuilderTimeOfDay extends FormBuilderField<TimeOfDay> {
  FormBuilderTimeOfDay({
    super.key,
    required super.name,
    required BuildContext context,
    super.validator,
    InputDecoration decoration = const InputDecoration(),
    super.initialValue,
    super.enabled,
  }) : super(
          builder: (field) => InputDecorator(
            decoration: decoration.copyWith(errorText: field.errorText),
            child: ListTile(
              // leading: const Icon(Icons.access_time_rounded),
              leading: field.value == null
                  ? const Icon(Icons.access_time_rounded)
                  : InkWell(
                      onLongPress: () => showAdaptiveDialog(
                          context: context,
                          builder: (context) => AlertDialog.adaptive(
                                  content: ClockWidget(
                                time: field.value!,
                                greater: true,
                              ))),
                      child: ClockWidget(time: field.value!)),
              title: Text(
                AppLocalizations.of(field.context)!.addingSelectedTime(
                    field.value?.format(field.context) ?? 'void'),
              ),
              trailing: IconButton(
                onPressed: () => field.didChange(null),
                icon: const Icon(CupertinoIcons.trash_fill),
              ),
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
