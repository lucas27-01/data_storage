import 'dart:convert';

import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/models/representable_data_types/representable_integer.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:data_storage/screens/route_generator.dart';
import 'package:data_storage/utils/file_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
            throw snapshot.error!;
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

  late Stream<List<DataStorage>> _dataStorageStream;

  //final _futureBuilderKey = GlobalKey<State<FutureBuilder>>();

  Future<List<DataStorage>> getUserData() async {
    var tmpDS = jsonDecode(await FileManager.getUserData())
        .map((el) => DataStorage.fromJson(el))
        .toList();
    List<DataStorage> listDataStorage = [];
    for (var ds in tmpDS) {
      if (ds is DataStorage) {
        listDataStorage.add(ds);
      }
    }
    return listDataStorage;
  }

  void _showSnackBar(BuildContext context, Widget child,
      [SnackBarAction? action]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: child,
      action: action,
    ));
  }

  @override
  void initState() {
    _dataStorageStream = FileManager.getDataStorageStream();

    super.initState();
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
      body: StreamBuilder(
        stream: _dataStorageStream,
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
                          title: Text(userData[index].name),
                          subtitle: userData[index].description != null
                              ? Text(userData[index].description!)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  var newDataStorage =
                                      await Navigator.of(context)
                                          .pushNamed<DataStorage?>(
                                    '/dataValueAdder',
                                    arguments: (await FileManager
                                        .getDataStorage())[index],
                                  );
                                  if (newDataStorage != null) {
                                    var oldDSs =
                                        await FileManager.getDataStorage();
                                    oldDSs[index] = newDataStorage;
                                    if (kDebugMode) {
                                      print(jsonEncode(oldDSs));
                                    }
                                    FileManager.saveUserData(
                                        jsonEncode(oldDSs));
                                  }
                                },
                                icon: const Icon(
                                  Icons.add_chart_rounded,
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    onTap: () async {
                                      DataStorage? newDataStorage;
                                      var oldDataStorages =
                                          await FileManager.getDataStorage();
                                      if (context.mounted) {
                                        newDataStorage = await Navigator
                                            .pushNamed<DataStorage?>(
                                          context,
                                          '/dataStorageCreator',
                                          arguments: oldDataStorages[index],
                                        );
                                      }
                                      if (newDataStorage != null) {
                                        oldDataStorages[index] = newDataStorage;
                                        FileManager.saveUserData(
                                            jsonEncode(oldDataStorages));
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(Icons.edit_rounded),
                                        Text(AppLocalizations.of(context)!.edit)
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog.adaptive(
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .attenction,
                                          ),
                                          content: SingleChildScrollView(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .questionDeleteDataStorage,
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                var oldDS = await getUserData();
                                                oldDS.removeAt(index);
                                                FileManager.saveUserData(
                                                    jsonEncode(oldDS));

                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              label: Text(
                                                AppLocalizations.of(context)!
                                                    .delete,
                                              ),
                                              icon: const Icon(
                                                  CupertinoIcons.delete_solid),
                                            ),
                                            FilledButton.icon(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              label: Text(
                                                AppLocalizations.of(context)!
                                                    .cancel,
                                              ),
                                              icon: const Icon(
                                                Icons.cancel_rounded,
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(CupertinoIcons.delete_solid),
                                        Text(
                                          AppLocalizations.of(context)!.delete,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          } else if (snapshotUserData.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(
                  "Something bad happened\nDebug info:\n${snapshotUserData.connectionState}\n${snapshotUserData.error}"),
            );
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
            onTap: () async {
              var newDataStorage = await Navigator.pushNamed<DataStorage?>(
                context,
                '/dataStorageCreator',
              );

              if (newDataStorage != null) {
                var dataStorage = await getUserData();
                dataStorage.add(newDataStorage);
                FileManager.saveUserData(
                  jsonEncode(
                    dataStorage.map((el) => el.toJson()).toList(),
                  ),
                );
              }
            },
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
          if (kDebugMode)
          SpeedDialChild(
            child: Icon(
              Icons.print_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Print Settings debug",
            onTap: () {
              // ignore: avoid_print
              print(
                  "Settings from provider: ${context.read<Settings>().toJson()}");
              FileManager.getSettings()
                  // ignore: avoid_print
                  .then((value) => print("Settings from file: $value"));
            },
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          if (kDebugMode)
          SpeedDialChild(
            child: Icon(
              Icons.print_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Print Data Storage debug",
            onTap: () {
              FileManager.getUserData().then((source) {
                // ignore: avoid_print
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
            onTap: () => FileManager.saveUserData(jsonEncode([
              DataStorage(
                name: "Void",
                data: [
                  Data(
                    name: "Num",
                    description: "Fot**ti",
                    type: RepresentableInteger(
                      values: {},
                      statsToSee: {},
                      defaultValue: 5,
                    ),
                  )
                ],
                description: "I want this empty",
              ).toJson()
            ])),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
