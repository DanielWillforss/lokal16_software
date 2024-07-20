// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/admin_data.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/visual/style.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  AdminData data = AdminData(names: {}, types: {});
  bool hasChanged = false;

  @override
  Widget build(BuildContext context) {

    data = ModalRoute.of(context)?.settings.arguments as AdminData? ?? data;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Admin", style: Style.headerText,)
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Names"),
              Tab(text: "EventTypes"),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if(hasChanged) {
                String? choice = await AlertHandeler.saveAndExit(context);
                if(choice != null) {
                  if(choice == "save") {
                    Navigator.pop(context, data);
                  } else if (choice == "exit") {
                    Navigator.pop(context);
                  }
                }
              } else {
                Navigator.pop(context);
              }
            }
          ),
        ),
        body: TabBarView(
          children: [
            DataCardList(
              isName: true,
              objects: data.names,  
              data: data,
              updateState: updateState,
            ),
            DataCardList(
              isName: false,
              objects: data.types,  
              data: data,
              updateState: updateState,
            )
          ],
        )
      ),
    );
  } 

  late Function updateState = () {
    setState(() {
      hasChanged = true;
    });
  };
}

class DataCardList extends StatelessWidget {
  
  final AdminData data;
  final Set<dynamic> objects;
  final bool isName;
  final Function updateState;

  const DataCardList({
    required this.objects, 
    required this.isName,
    required this.data, 
    required this.updateState, 
    super.key, 
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = objects.map((object) => Card(
      color: isName ? Colors.red : Colors.amber,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Center(child: Text(object.toString()))
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                isName ?
                  data.names.remove(object):
                  data.types.remove(object)
                ;
                updateState();
              },
              icon: const Icon(Icons.delete_outline),
              color: Colors.black,
            )
          )
        ],
      )
    )).toList();
    cards.add(
      Card(
        child: ElevatedButton(
          onPressed: () async {
            String? result = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                String tempInput = '';
                return AlertDialog(
                  title: const Text('Lägg till ny'),
                  content: TextField(
                    onChanged: (value) {
                      tempInput = value;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Avbryt'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(tempInput); // Confirm the input
                      },
                      child: const Text('Bekräfta'),
                    ),
                  ],
                );
              },
            );

            if (result != null) {
              isName ? 
                data.names.add(Name(
                  firstName: result,
                  lastName: "test",
                  personalNumber: "test",
                  member: true,
                )) :
                data.types.add(result);
              updateState();
            }
          },
          child: const Text("Lägg till ny")
        ),
      ),
    );
    
    return Center(
      child: ListView(
        children: cards,
      )
    );
  }
}

