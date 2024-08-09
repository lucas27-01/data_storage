import 'dart:convert';

import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:data_storage/screens/route_generator.dart';
import 'package:data_storage/utils/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              child: const DataStorageApp(),
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

class DataStorageApp extends StatelessWidget {
  const DataStorageApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.watch<Settings>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FormBuilderLocalizations.delegate,
      ],
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

  Future<List<dynamic>?> getUserData() async {
    return jsonDecode(await FileManager.getUserData())
        .map((el) => DataStorage.fromJson(el))
        .toList();
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
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.appName,
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
                title: Text(AppLocalizations.of(context)!.settingsPageName),
                onTap: () => Navigator.pushNamed(
                      context,
                      '/settings',
                    )),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(AppLocalizations.of(context)!.aboutPageName),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.appName),
        actions: <Widget>[
          PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.settings_rounded),
                          Text(AppLocalizations.of(context)!.settingsPageName),
                        ],
                      ),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.info_outline_rounded),
                          Text(AppLocalizations.of(context)!.aboutPageName),
                        ],
                      ),
                      onTap: () => _showSnackBar(
                          context,
                          Text(AppLocalizations.of(context)!.funNotImplemented),
                          SnackBarAction(
                              label: AppLocalizations.of(context)!.ok,
                              onPressed: () {})),
                    )
                  ])
        ],
      ),
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshotUserData) {
          if (snapshotUserData.hasError) {
            throw snapshotUserData.error!;
          } else if (snapshotUserData.hasData) {
            var userData = snapshotUserData.data!;
            return ListView.builder(
                itemCount: userData.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, '/dataStorageViewer',
                        arguments: userData[index]),
                    child: Hero(
                      tag: userData[index].id,
                      child: Card(
                        child: ListTile(
                          leading: userData[index].iconWidget,
                          title: Text(userData[index].name),
                          subtitle: userData[index].description !=null? Text(userData[index].description):null,
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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
            onTap: () => Navigator.pushNamed(
              context,
              '/dataStorageCreator',
            ),
            label: AppLocalizations.of(context)!.addStorage,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          SpeedDialChild(
            child: Icon(
              Icons.create_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: AppLocalizations.of(context)!.addStorageFromTemplate,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          SpeedDialChild(
            child: Icon(
              Icons.print_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Print Settings debug",
            onTap: () {
              print(
                  "Settings from provider: ${context.read<Settings>().toJson()}");
              FileManager.getSettings()
                  .then((value) => print("Settings from file: $value"));
            },
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          SpeedDialChild(
            child: Icon(
              Icons.print_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Print Data Storage debug",
            onTap: () {
              FileManager.getUserData().then((source) {
                print(source);
              });
            },
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          SpeedDialChild(
            child: Icon(
              Icons.print_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Reset User data",
            onTap: () => FileManager.saveUserData(
                jsonEncode([DataStorage(name: "Void", data: [], description: "I want this empty", icon: Icons.lock_clock_rounded).toJson()])),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
