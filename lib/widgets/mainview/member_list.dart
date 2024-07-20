import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/widgets/mainview/member_card.dart';

class MemberList extends StatelessWidget {

  final DataNew data;
  final Function updateData;

  const MemberList({
    required this.data, 
    required this.updateData,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    List<String> namesList = [];
    List<String> notCheckedIn = [];
    Map<String, Set<Event>> splitByPerson = data.getSplitByName();
    Set<String> names = data.getNames();
    for(String name in names) {
      if(Event.isCheckedIn(splitByPerson[name]?? {})) {
        namesList.add(name);
      } else {
        notCheckedIn.add(name);
      }
    }
    namesList.addAll(notCheckedIn);

    List<Widget> list = namesList.map<Widget>((element) => MemberCard(
      name: element, 
      data: data,
      updateData: updateData,
    )).toList();

    if(list.length % 2 != 0) {
      list.add(const Card());
    }

    List<Widget> sideBySide = [];
    for(int i = 0; i < list.length / 2; i++) {
      sideBySide.add(
        Row(
          children: [
            Expanded(child: list[i*2]),
            Expanded(child: list[i*2+1])
          ],
        )
      );
    }

    return Center(
        child: ListView(
          children: sideBySide,
        )
    );
  }
}