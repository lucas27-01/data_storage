import 'package:data_storage/models/data.dart';
import 'package:data_storage/models/data_storage.dart';
import 'package:data_storage/models/representable_data_types/representable_data_type.dart';
import 'package:data_storage/widgets/expandable_section.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DataStorageViewer extends StatelessWidget {
  const DataStorageViewer({super.key, required this.dataStorage});
  final DataStorage dataStorage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.viewerOf(dataStorage.name)),
      ),
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: dataStorage.id,
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 0,
              child: ListTile(
                title: Text(dataStorage.name),
                subtitle: dataStorage.description != null
                    ? Text(dataStorage.description!)
                    : null,
              ),
            ),
          ),
          for (Data data in dataStorage.data)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpandableSection(
                isExpanded: true,
                title: Row(
                  children: [
                    Icon(RepresentableDataType
                        .representableDataTypeAsIcon[data.type.runtimeType]),
                    const SizedBox(width: 10),
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: data.getViewer(),
              ),
            )
        ],
      ),
    );
  }
}
