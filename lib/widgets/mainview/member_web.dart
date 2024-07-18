import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/visual/style.dart';
import 'package:lokal16_software/widgets/mainview/member_card.dart';

class MemberWeb extends StatefulWidget {
  final double size;
  final Data data;
  final Function editData;

  const MemberWeb({
    super.key, 
    required this.size, 
    required this.data,
    required this.editData,
  });

  @override
  State<MemberWeb> createState() =>
      _MemberWebState();
}

class _MemberWebState extends State<MemberWeb> {
  Offset position = const Offset(0, 0);
  double scale = 1.0;
  Offset initialFocalPoint = Offset.zero;
  Offset initialPosition = Offset.zero;
  double initialScale = 1.0;
  double scaleRatio = 4;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onScaleStart: (details) {
        initialFocalPoint = details.focalPoint;
        initialPosition = position;
        initialScale = scale;
      },
      onScaleUpdate: (details) {
        setState(() {
          scale = initialScale * details.scale;
          position = initialPosition + (details.focalPoint - initialFocalPoint);
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Transform.translate(
        offset: position,
        child: Transform.scale(
          scale: scale * scaleRatio,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: PositionedStack(
              midpoint: widget.size / 2,
              scaleRatio: scaleRatio, 
              data: widget.data,
              editData: widget.editData,
            )
          ),
        ),
      ),
    );
  }
}

class PositionedStack extends StatelessWidget {
  final double midpoint;
  final double scaleRatio;
  final Data data;
  final Function editData;

  const PositionedStack({
    super.key, 
    required this.midpoint, 
    required this.scaleRatio, 
    required this.data,
    required this.editData,
  });

  @override
  Widget build(BuildContext context) {

    final double radius = 100/scaleRatio;
    const double angleIncrement = 2 * pi / 6;
    int layer = 1;
    int j = 0;

    List<String> namesList = [];
    List<String> notCheckedIn = [];
    Map<String, List<Event>> splitByPerson = data.getSplitByPerson();

    for(String name in data.names) {
      if(Event.isCheckedIn(splitByPerson[name]?? [])) {
        namesList.add(name);
      } else {
        notCheckedIn.add(name);
      }
    }
    namesList.addAll(notCheckedIn);

    List<Positioned> idAsWidgets = [];
    
    for (int i = 0; i< namesList.length; i++) {

      //Math
      final double angle = i * angleIncrement / layer;
      final double x = midpoint + (radius * (1.3) * layer * cos(angle));
      final double y = midpoint + (radius * layer * sin(angle));

      idAsWidgets.add(Positioned(
        left: x,
        top: y,
        child: Transform.scale(
          scale: 1/scaleRatio, 
          child: SizedBox(
            width: 120,
            height: 50,
            child: MemberCard(
              name: namesList[i],
              data: data,
              editData: editData,
            ),
          ))
      ));

      j++;
      if(j >= 6 * layer) {
        j = 0;
        layer++;
      }
    }

    idAsWidgets.add(Positioned(
      left: midpoint + 28,
      top: midpoint - 8,
      child: Transform.scale(scale: 1/scaleRatio, child: const ImageIcon(
        AssetImage('assets/l16icon.png'),
        size: 64,
        color: Style.blue,
      ))
    ));

    return Transform.scale(
      scale: 1,
      child: Stack(
        children: idAsWidgets,
      ),
    );
  }
}