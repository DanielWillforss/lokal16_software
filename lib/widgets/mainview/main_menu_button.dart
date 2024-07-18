// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/util/alerts.dart';

class MainMenuButton extends StatelessWidget {

  final Data data;
  //final bool isOnline;
  //final Function flipIsOnline;
  final Function updateData;
  final Future<void> Function() reloadData;

  const MainMenuButton({
    required this.data,
    //required this.isOnline,
    //required this.flipIsOnline,
    required this.updateData,
    required this.reloadData,
    super.key, 
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) async {
        switch (result) {
          case 'admin':
            await AlertHandeler.dialogWhileComputing(context, reloadData);
            Data? newData = await Navigator.pushNamed(context, "/admin", arguments: data.deepCopy()) as Data?;
            if(newData != null) {
              AlertHandeler.dialogWhileComputing(context, () async {
                await updateData(newData);
              });
            }
            break;
          //case 'toggleOnline':
          //  flipIsOnline();
          //  break;
          case 'reload':
            AlertHandeler.dialogWhileComputing(context, reloadData);
          case 'findOverlap':
            bool found = data.findCollitions();
            if(found) {
              AlertHandeler.newAlert(context, Alerts.collitions);
            } else {
              AlertHandeler.newAlert(context, Alerts.noCollitions);
            }
            break;
          case 'showOverlap':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                List<Widget> list = data.overlapping.isEmpty 
                  ? [const Center(child: Text("Inga överlappande händelser"))]
                  : data.overlapping.map((Event event) =>
                    Center(child: Text(event.toString()),)
                  ).toList();
                return SimpleDialog(
                  title: const Center(child: Text("Alla överlappande händelser")),
                  children: list,
                );
              },
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'admin',
          child: Text('Adminsida'),
        ),
        //PopupMenuItem<String>(
        //  value: 'toggleOnline',
        //  child: Text("Byt till ${isOnline ? "offline" : "online"}"),
        //),
        const PopupMenuItem<String>(
          value: 'reload',
          child: Text("Uppdatera data"),
        ),
        const PopupMenuItem<String>(
          value: 'findOverlap',
          child: Text("Sök efter överlappande händelser"),
        ),
        const PopupMenuItem<String>(
          value: 'showOverlap',
          child: Text("Visa överlappande händelser"),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}