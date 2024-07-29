import 'package:data_storage/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  final Map<Color, String> colorNames = {
    Colors.amber: 'Amber',
    Colors.blue: 'Blue',
    Colors.red: 'Red',
    Colors.cyan: 'Cyan',
    Colors.green: 'Green',
    Colors.yellow: 'Yellow',
    Colors.orange: 'Orange',
    Colors.blueGrey: 'Blue Grey',
    Colors.deepPurple: 'Purple',
    Colors.indigo: 'Indigo',
    Colors.lime: 'Lime',
    Colors.pink: 'Pink',
    Colors.teal: 'Teal',
  };

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
            const Row(
              children: [
                Text("Theme",
                    style:
                        TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
              ],
            ),
            Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(" Dark mode:"),
                      Switch(
                        value: context.watch<Settings>().brightnessTheme ==
                            Brightness.dark,
                        onChanged: (_) {
                          context.read<Settings>().reverseBrightnessTheme();
                        },
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(" Theme color:"),
                      PopupMenuButton<Color>(
                        onSelected: (color) => context.read<Settings>().setColorTheme(color: color),
                        itemBuilder: (context) => <PopupMenuEntry<Color>>[
                          for (var entry in colorNames.entries)
                            PopupMenuItem(
                              value: entry.key,
                              child: Text(entry.value, style: TextStyle(color: entry.key),),
                            )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
