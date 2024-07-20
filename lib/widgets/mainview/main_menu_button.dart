// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/changes.dart';
import 'package:lokal16_software/classes/data/admin_data.dart';
import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/util/alerts.dart';

class MainMenuButton extends StatelessWidget {

  final DataNew data;
  final Function(Changes) updateData;
  final Future<void> Function() reloadData;

  const MainMenuButton({
    required this.data,
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
            AdminData? newData = await Navigator.pushNamed(context, "/admin", arguments: data.getAdminData());
            if(newData != null) {
              AlertHandeler.dialogWhileComputing(context, () async {
                await updateData(newData.changes);
              });
            }
            break;
          case 'reload':
            AlertHandeler.dialogWhileComputing(context, reloadData);
          case 'findOverlap':
            bool found = data.findOverlap();
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