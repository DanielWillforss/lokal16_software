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
              Tab(text: "Användare"),
              Tab(text: "Aktiviteter"),
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
              objects: data.getNamesSortedByName(),  
              data: data,
              updateState: updateState,
            ),
            DataCardList(
              isName: false,
              objects: data.getTypesSortedByName(),  
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

class DataCardList extends StatefulWidget {
  
  final AdminData data;
  final List<dynamic> objects;
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
  State<DataCardList> createState() => _DataCardListState();
}

class _DataCardListState extends State<DataCardList> {

  final ScrollController scrollController = ScrollController();
  final String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ";

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    int nbrOfCards = widget.objects.length;
    List<int> nbrOfEach = List<int>.filled(30, 1);
    List<Widget> cards = [];
    
    cards.add(
      Card(
        child: ElevatedButton(
          onPressed: () async {
            Map<String, String>? result = await showDialog<Map<String, String>>(
              context: context,
              builder: (BuildContext context) {
                Map<String, String> input = {};
                return AlertDialog(
                  title: const Text('Lägg till ny'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.isName ? 
                    [
                      TextField(
                        onChanged: (value) {
                          input['firstName'] = value;
                        },
                        decoration: const InputDecoration(
                          hintText: "Förnamn"
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          input['lastName'] = value;
                        },
                        decoration: const InputDecoration(
                          hintText: "Efternamn"
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          input['personalNumber'] = value;
                        },
                        decoration: const InputDecoration(
                          hintText: "Personnummer"
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          input['paidFee'] = value;
                        },
                        decoration: const InputDecoration(
                          hintText: "Medlemsavgift"
                        ),
                      ),
                    ] :
                    [
                      TextField(
                        onChanged: (value) {
                          input['type'] = value;
                        },
                        decoration: const InputDecoration(
                          hintText: "Aktivitet"
                        ),
                      ),
                    ],
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
                        Navigator.of(context).pop(input); // Confirm the input
                      },
                      child: const Text('Bekräfta'),
                    ),
                  ],
                );
              },
            );

            if (result != null) {
              if(widget.isName) {
                widget.data.addName(Name(
                  firstName: result["firstName"] ?? "",
                  lastName: result["lastName"] ?? "",
                  personalNumber: result["personalNumber"] ?? "",
                  paidFee: int.tryParse(result["paidFee"] ?? ""),
                ));
              } else {
                widget.data.addType(result["type"] ?? "");
              } 
              widget.updateState();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isName ? Style.green : Style.yellow,
          ),
          child: Text("Lägg till ny ${widget.isName ? "användare" : "aktivitet"}")
        ),
      ),
    );

    for(dynamic object in widget.objects) {

      int index = alphabet.indexOf(object.toString()[0]) + 1;
      nbrOfEach[index]++;

      cards.add(
        Card(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Center(child: Text(widget.isName ? (object as Name).toFullStringExtended() : object.toString()))
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () async{
                    bool? confirmation = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Radera ${widget.isName ? "användare" : "aktivitet"}"),
                          content: Text("Är du säker att du vill radera denna ${widget.isName ? "användare" : "aktivitet"}?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Return 'Option 1' when pressed
                              },
                              child: const Text("Bekräfta"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Return 'Option 1' when pressed
                              },
                              child: const Text("Avbryt"),
                            ),
                          ],
                        );
                      }
                    );
                    if(confirmation == true) {
                      widget.isName ?
                        widget.data.removeName(object):
                        widget.data.removeType(object)
                      ;
                      widget.updateState();
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.black,
                )
              )
            ],
          )
        )
      );
    }
    
    

    List<int> indexOfEach = List<int>.filled(29, 0);
    indexOfEach[0] = nbrOfEach[0];
    for(int i = 1; i<29; i++) {
      indexOfEach[i] = indexOfEach[i-1] + nbrOfEach[i];
    }

    void scrollToIndex(int index) {
    // Calculate the position to scroll to
      double cardsOnScreen = 20;
      double position = scrollController.position.maxScrollExtent * indexOfEach[index] / (nbrOfCards-1+cardsOnScreen);
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: ListView(
            controller: scrollController,
            children: cards,
          ),
        ),
        widget.isName 
        ? Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 30, // Adjust the width of the button column
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(29, (index) {
                return GestureDetector(
                  onTap: () {
                    scrollToIndex(index);
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.height-100)/35, // Height of each button
                    //margin: EdgeInsets.symmetric(vertical: 2),
                    color: Style.blue,
                    alignment: Alignment.center,
                    child: Text(
                      alphabet[index],
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                );
              }),
            ),
          ),
        ) 
        : Container(),
      ],
    );
  }
}

