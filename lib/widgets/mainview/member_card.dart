// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/visual/style.dart';

class MemberCard extends StatelessWidget {

  final String name;
  final Data data;
  final Function editData;

  const MemberCard({
    required this.name, 
    required this.data, 
    required this.editData,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    Map<String, List<Event>> splitByPerson = data.getSplitByPerson();

    return Card(
      child: FloatingActionButton(
        backgroundColor: Style.memberButtonColor(Event.isCheckedIn(splitByPerson[name] ?? [])),
        heroTag: name,
        onPressed: () async {

          Map<String, dynamic>? returnData = await Navigator.pushNamed(
            context, 
            '/page', 
            arguments: {
              'name' : name,
              'eventTypes' : data.eventTypes.toList(),
              'eventList' : splitByPerson[name] ?? [],
            }
          ) as Map<String, dynamic>?;
          
          if(returnData != null) {
            await AlertHandeler.dialogWhileComputing(context, () async {
              await data.mergeWithPageReturn(returnData, name, context);
              await editData(data);
            });
          }
        },
        child: Text(name, textAlign: TextAlign.center,),
      ),
    );
  }
}