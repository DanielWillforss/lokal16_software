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
    List<List<Widget>> listByLetter = List.generate(
      30, 
      (index) => index == 0 ? [] :[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 120),
          child: SizedBox(
            height: 48,
            width:  60,
            child: Container(
              color: Colors.grey,
              child: Center(
                child: Text(
                  alphabet[index-1],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        )
      ]);
    List<Widget> list = [];

    for(Name name in sortedNames) {
      int index = alphabet.indexOf(name.firstName[0]) + 1;
      
      listByLetter[index].add(SizedBox(
        height: 60,
        child: MemberCard(
          name: name, 
          data: widget.data,
          updateData: widget.updateData,
        ),
      ));
    }
    List<int> indexOfEach = List<int>.filled(29, 0);
    indexOfEach[0] = listByLetter[0].length;
    for(int i = 1; i<29; i++) {
      indexOfEach[i] = indexOfEach[i-1] + listByLetter[i].length;
    }

    for(List<Widget> subList in listByLetter) {
      list.addAll(subList);
    }

    void scrollToIndex(int index) {
    // Calculate the position to scroll to
      double cardsOnScreen = 17;
      double position = scrollController.position.maxScrollExtent * indexOfEach[index] / (list.length-1-cardsOnScreen);
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