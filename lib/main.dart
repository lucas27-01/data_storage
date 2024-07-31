import 'dart:convert';

import 'package:data_storage/models/user_settings.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:data_storage/screens/route_generator.dart';
import 'package:data_storage/utils/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FileManager.getSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (_) =>
                        Settings.fromJson(jsonDecode(snapshot.data!)))
              ],
              child: const DataStorage(),
            );
          } else if (snapshot.hasError) {
            throw Exception("Error Occurred");
          } else {
            return const Center(
                child: CircularProgressIndicator(color: Colors.teal));
          }
        });
  }
}

class DataStorage extends StatelessWidget {
  const DataStorage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Storage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: context.watch<Settings>().colorTheme,
          brightness: context.watch<Settings>().brightnessTheme,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  int _counter = 0;
  late Map<String, String> language;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<Map<String, dynamic>> loadLanguage(Locales locale) async {
    String jsonString =
        await rootBundle.loadString('assets/langs/${locale.name}.json');
    final jsonResponse = json.decode(jsonString);
    return jsonResponse;
  }

  void _showSnackBar(BuildContext context, Widget child,
      [SnackBarAction? action]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: child,
      action: action,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadLanguage(context.watch<Settings>().locale),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              drawer: Drawer(
                child: ListView(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      alignment: Alignment.center,
                      child: Text(
                        snapshot.data!["appName"],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/data-storage-no-background.png',
                      height: 250,
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_rounded),
                      title: Text(snapshot.data!["settingsPageName"]),
                      onTap: () => Navigator.pushNamed(context, '/settings',
                          arguments: snapshot.data),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(snapshot.data!["aboutPageName"]),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(snapshot.data!["appName"]),
                actions: <Widget>[
                  PopupMenuButton(
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.settings_rounded),
                                  Text(snapshot.data!["settingsPageName"]),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/settings',
                                    arguments: snapshot.data);
                              },
                            ),
                            PopupMenuItem(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.info_outline_rounded),
                                  Text(snapshot.data!["aboutPageName"]),
                                ],
                              ),
                              onTap: () => _showSnackBar(
                                  context,
                                  Text(snapshot.data!["funNotImplemented"]),
                                  SnackBarAction(
                                      label: snapshot.data!["ok"],
                                      onPressed: () {})),
                            )
                          ])
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              floatingActionButton: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                children: [
                  SpeedDialChild(
                    child: Icon(
                      Icons.add_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () => _showSnackBar(
                        context,
                        Text(snapshot.data!['funNotImplemented']),
                        SnackBarAction(
                            label: snapshot.data!['ok'], onPressed: () {})),
                    label: "Add Storage",
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    labelBackgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  SpeedDialChild(
                    child: Icon(
                      Icons.create_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: "Add Storage from Template",
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    labelBackgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  SpeedDialChild(
                    child: Icon(
                      Icons.print_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: "Print debug",
                    onTap: () {
                      print("Settings from provider: ${context.read<Settings>().toJson()}");
                      FileManager.getSettings().then((value) => print("Settings from file: $value"));
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    labelBackgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ],
              ), // This trailing comma makes auto-formatting nicer for build methods.
            );
          } else if (snapshot.hasError) {
            return const Text("Error occurred");
          } else {
            return const Center(
                child: CircularProgressIndicator(color: Colors.teal));
          }
        });
  }
}
