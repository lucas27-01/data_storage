import 'package:data_storage/models/data_storage.dart';
import 'package:flutter/material.dart';

class DataStorageViewer extends StatelessWidget {
  const DataStorageViewer({super.key, required this.dataStorage});
  final DataStorage dataStorage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(dataStorage.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
              tag: dataStorage.id,
              child: Card(
                child: ListTile(
                  title: Text(dataStorage.name),
                  subtitle: dataStorage.description != null
                      ? Text(dataStorage.description!)
                      : null,
                ),
              ))
        ],
      ),
    );
  }
}
