// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:lokal16_software/classes/data/member_data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/visual/style.dart';

class MemberCard extends StatelessWidget {

  final String name;
  final DataNew data;
  final Function updateData;

  const MemberCard({
    required this.name, 
    required this.data, 
    required this.updateData,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    Map<String, Set<Event>> splitByPerson = data.getSplitByName();

    return Card(
      child: FloatingActionButton(
        backgroundColor: Style.memberButtonColor(Event.isCheckedIn(splitByPerson[name] ?? {})),
        heroTag: name,
        onPressed: () async {

          MemberData? returnData = await Navigator.pushNamed(
            context, 
            '/page', 
            arguments: data.getMemberData(name)
          );
          
          if(returnData != null) {
            await AlertHandeler.dialogWhileComputing(context, () async {
              await updateData(returnData.changes);
            });
          }
        },
        child: Text(name, textAlign: TextAlign.center,),
      ),
    );
  }
}