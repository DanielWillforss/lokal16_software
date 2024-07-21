import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/visual/style.dart';
import 'package:lokal16_software/widgets/mainview/member_card.dart';

class MemberList extends StatefulWidget {

  final DataNew data;
  final Function updateData;

  const MemberList({
    required this.data, 
    required this.updateData,
    super.key
  });

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  
  final ScrollController scrollController = ScrollController();
  final String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ";

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    List<Name> sortedNames = widget.data.getNamesSortedByName();
    int nbrOfCards = sortedNames.length;
    List<int> nbrOfEach = List<int>.filled(30, 0);
    List<Widget> list = [];

    for(Name name in sortedNames) {
      int index = alphabet.indexOf(name.firstName[0]) + 1;
      nbrOfEach[index]++;
      
      list.add(MemberCard(
        name: name, 
        data: widget.data,
        updateData: widget.updateData,
      ));
    }
    List<int> indexOfEach = List<int>.filled(29, 0);
    indexOfEach[0] = nbrOfEach[0];
    for(int i = 1; i<29; i++) {
      indexOfEach[i] = indexOfEach[i-1] + nbrOfEach[i];
    }

    void scrollToIndex(int index) {
    // Calculate the position to scroll to
    double position = scrollController.position.maxScrollExtent * indexOfEach[index] / nbrOfCards-1;
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
            children: list,
          ),
        ),
        Align(
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
        ),
      ],
    );
  }
}