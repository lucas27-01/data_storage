import 'dart:convert';

import 'package:data_storage/models/user_settings.dart';
import 'package:data_storage/providers/settings.dart';
import 'package:data_storage/screens/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => Settings())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

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
                      onTap: () => Navigator.pushNamed(context, '/settings', arguments: snapshot.data),
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
                                Navigator.pushNamed(context, '/settings', arguments: snapshot.data);
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
                              onTap: () {
                                final notImplementedSnackBar = SnackBar(
                                  content: Text(
                                    snapshot.data!["funNotImplemented"],
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                  action: SnackBarAction(
                                    label: snapshot.data!["ok"],
                                    onPressed: () {},
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(notImplementedSnackBar);
                              },
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
              floatingActionButton: FloatingActionButton(
                onPressed: () =>
                    print(jsonEncode(context.read<Settings>().toJson())),
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            );
          } else if (snapshot.hasError) {
            return const Text("Error occurred");
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
