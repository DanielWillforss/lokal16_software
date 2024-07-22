// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:lokal16_software/classes/data/member_data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/util/data_util.dart';
import 'package:lokal16_software/visual/style.dart';

class MemberCard extends StatelessWidget {

  final Name name;
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
        backgroundColor: Style.memberButtonColor(isCheckedIn(splitByPerson[name.toFullString()] ?? {})),
        heroTag: name,
        onPressed: () async {
          MemberData arg = data.getMemberData(name);
          MemberData? returnData = await Navigator.pushNamed(
            context, 
            '/page', 
            arguments: arg,
          ) as MemberData?;
          
          if(returnData != null) {
            updateData(returnData.changes);
          }
        },
        child: Text(name.toString(), textAlign: TextAlign.center,),
      ),
    );
  }
}