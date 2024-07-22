import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/visual/style.dart';
import 'package:lokal16_software/widgets/mainview/member_card.dart';

class MemberWeb extends StatelessWidget {
  late final Size midpoint;
  late final DataNew data;
  late final Function updateData;

  MemberWeb({
    super.key, 
    required Size size, 
    required this.data,
    required this.updateData,
  }) {
    Offset offset = const Offset(-60, -80);
    midpoint = size/2 + offset;
  }

  @override
  Widget build(BuildContext context) {

    const double radius = 100;
    const double angleIncrement = 2 * pi / 6;
    int layer = 1;
    int j = 0;

    List<Name> sortedNames = data.getNamesSortedByCheckin();
    List<Positioned> idAsWidgets = [];
    
    for(int i = 0; i<90;i++) {
      if(
        (i >= 18 && i <= 19 ) ||
        (i >= 26 && i <= 28 ) ||
        (i >= 35 && i <= 39 ) ||
        (i >= 45 && i <= 51 ) ||
        (i >= 57 && i <= 64 ) ||
        (i >= 71 && i <= 79 ) ||
        (i >= 86 && i <= 89 )
      ) {
        if(i<sortedNames.length) {
          sortedNames.insert(i, Name(firstName: "", lastName: "", personalNumber: "", paidFee: 200));
        }
      }
    }

    for (int i = 0; i< sortedNames.length && i<90; i++) {

      //Math
      final double angle = i * angleIncrement / layer;
      final double x = midpoint.width + (radius * (1.3) * layer * cos(angle));
      final double y = midpoint.height + (radius * layer * sin(angle));

      idAsWidgets.add(Positioned(
        left: x,
        top: y,
        child: SizedBox(
          width: 120,
          height: 50,
          child: MemberCard(
            name: sortedNames[i],
            data: data,
            updateData: updateData,
          ),
        )
      ));

      j++;
      if(j >= 6 * layer) {
        j = 0;
        layer++;
      }
    }

    idAsWidgets.add(Positioned(
      left: midpoint.width + 28,
      top: midpoint.height - 8,
      child: const ImageIcon(
        AssetImage('assets/l16icon.png'),
        size: 64,
        color: Style.blue,
      )
    ));

    return Stack(
      children: idAsWidgets,
    );
  }
}