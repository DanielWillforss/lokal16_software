// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/member_data.dart';
import 'package:lokal16_software/classes/time/event_date.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:lokal16_software/visual/style.dart';
import 'package:lokal16_software/widgets/memberpage/date_card.dart';
import 'package:lokal16_software/widgets/memberpage/event_card.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {

  MemberData? data;

  bool wasChanged = false;
  bool deleting = false;
  Timer? inactiveTimer;

  @override
  void dispose() {
    inactiveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    data ??= ModalRoute.of(context)?.settings.arguments as MemberData? ?? MemberData.empty();

    inactiveTimer?.cancel();
    inactiveTimer = Timer(const Duration(seconds: 10), () {
      if(ModalRoute.of(context)?.isCurrent == true) {
        if(wasChanged) {
          Navigator.pop(context, data);
        } else {
          Navigator.pop(context);
        } 
      }
    });

    List<Widget> cardList = [];
    List<Event> eventList = [];
    for (var event in data!.events) {
      if(showEvent(event)) {
        eventList.add(event);
      }
    } 
    eventList.sort();
    int i = 0;

    for(i = 0; i<eventList.length; i++) {

      //Adding each eventCard
      cardList.add(EventCard(
        data: data!,
        updateData: updateData,
        deleting: deleting,
        event: eventList[i], 
        previousEvent: i != 0 ? eventList[i-1] : null,
        nextEvent: i == eventList.length - 1 ? null : eventList[i+1],
      ));
    }
    //Adding the "add new card"
    cardList.add(EventCard(
      data: data!,
      updateData: updateData,
      deleting: false,
      event: null,
      previousEvent: i != 0 ? eventList[i-1] : null,
      nextEvent: null,
    ));
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Style.pink,
        title: Center(child: Text(data!.name.toString(), style: Style.headerText)),
        leading: IconButton(
          iconSize: 36,
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if(wasChanged) {
              Navigator.pop(context, data);
            } else {
              Navigator.pop(context);
            } 
          },
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: deleting ? Colors.white : Style.pink,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  deleting = !deleting;
                });
              },
            ),
          ),
        ],
        bottom: DateCard(
          date: data!.currentDate,
          changeToDate: updateCurrentDate,
        ),
      ),
      body: Center(
        child: ListView(
          children: cardList,
        ),
      ),
    );
  }

  late Function updateCurrentDate = (EventDate newDate) {
    setState(() {
      data!.currentDate = newDate;  
    });
  };

  late Function updateData = () {  
    setState(() {
      wasChanged = true;
    });
  };

  bool showEvent(Event event) {
    EventDate date = data!.currentDate;
    return (event.endTime == null && Time.isTimeBefore(event.startTime, Time.fromEventDate(date)))
      || Time.sameDayAs(Time.fromEventDate(date), event.startTime)
      || Time.sameDayAs(Time.fromEventDate(date), event.endTime)
      || Time.isBetween(Time.fromEventDate(date), event.startTime, event.endTime);
  }
}