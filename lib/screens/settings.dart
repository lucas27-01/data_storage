import 'package:data_storage/models/theme_settings.dart';
import 'package:data_storage/models/user_settings.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.language});
  final Map<String, dynamic> language;

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //leading: Icon(Icons.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(widget.language["theme"],
                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
            Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(context.watch<Settings>().brightnessTheme ==
                            Brightness.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded),
                    title: Text(widget.language["darkModeWithColon"]),
                    trailing: Switch(
                      value: context.watch<Settings>().brightnessTheme ==
                          Brightness.dark,
                      onChanged: (_) {
                        context.read<Settings>().reverseBrightnessTheme();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(widget.language["themeColorWithColon"]),
                    leading: Icon(
                      Icons.color_lens,
                      color: context.watch<Settings>().colorTheme,
                    ),
                    trailing: DropdownButton<Color>(
                      value: context.watch<Settings>().colorTheme,
                      menuMaxHeight: 350,
                      onChanged: (value) {
                        context.read<Settings>().setColorTheme(color: value!);
                      },
                      items: [
                        for (var entry in ThemeSettings.colorNames.entries)
                          DropdownMenuItem<Color>(
                              value: entry.key,
                              child: Text(entry.value,
                                  style: TextStyle(color: entry.key)))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.language["lang"],
                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
            Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(widget.language["langWithColon"]),
                trailing: DropdownButton<Locales>(
                  value: context.watch<Settings>().locale,
                  menuMaxHeight: 350,
                  onChanged: (value) =>
                      context.read<Settings>().setLocale(locale: value!),
                  items: [
                    for (var entry in UserSettings.languagePerLocale.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
