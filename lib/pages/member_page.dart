// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/member_data.dart';
import 'package:lokal16_software/classes/time/event_date.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/visual/style.dart';
import 'package:lokal16_software/widgets/memberpage/date_card.dart';
import 'package:lokal16_software/widgets/memberpage/event_card.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {

  //Map<String, dynamic> data = {
  //  'name' : "",
  //  'eventTypes' : <String>[],
  //  'eventList' : <Event>[]
  //};
  MemberData data = MemberData(
    name: "",
    types: {},
    events: {},
  );

  bool wasChanged = false;
  bool deleting = false;
  EventDate currentDate = EventDate.now();

  @override
  void initState() {
    super.initState();
    
    Future.microtask(() {
      setState(() {
        data = ModalRoute.of(context)?.settings.arguments as MemberData? ?? data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> cardList = [];
    List<Event> eventList = data.events.toList(); 
    int i = 0;

    for(i = 0; i<eventList.length; i++) {
      Event event = eventList[i];

      if(showEvent(event)) {
        //Adding each eventCard
        cardList.add(EventCard(
          name: data.name, 
          updateEvent: updateEvent,
          updateEventTypes: updateEventTypes,
          eventTypes: data.types,
          deleting: deleting,
          event: event, 
          previousEvent: i != 0 ? eventList[i-1] : null,
          nextEvent: i == eventList.length - 1 ? null : eventList[i+1],
        ));
      }
    }
    //Adding the "add new card"
    cardList.add(EventCard(
      name: data.name, 
      updateEvent: updateEvent,
      updateEventTypes: updateEventTypes,
      eventTypes: data.types,
      deleting: false,
      event: null,
      previousEvent: i != 0 ? eventList[i-1] : null,
      nextEvent: null,
    ));
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Style.pink,
        title: Center(child: Text(data.name, style: Style.headerText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if(wasChanged) {
              String? choice = await AlertHandeler.saveAndExit(context);
              if(choice != null) {
                if(choice == "save") {
                  Navigator.pop(context, data);
                } else if (choice == "exit") {
                  Navigator.pop(context);
                }
              }
            } else {
              Navigator.pop(context);
            } 
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'delete':
                  setState(() {
                    deleting = !deleting;
                  });
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Toggle "Ta bort Händelse"'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
        bottom: DateCard(
          date: currentDate,
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

  late Function(Event, String) updateEvent = (Event event, String message) {

    List<Event> eventList = data.events.toList();
    if(message == "newEvent") {
      eventList.add(event);
      data.changes.addEvent(event);
    } else if(message == "updateEvent") {
      event.isChanged = true;
      for (int i = 0; i < eventList.length; i++) {
        if (eventList[i].startTime == event.startTime) {
          eventList[i] = event;
          break;
        }
      }
    } else if(message == "deleteEvent") {
      if(event.id != null) {
        data.changes.removeEvent(event);
      }
    } else {
      throw Exception();
    }

    setState(() {
      wasChanged = true;
    });
  };

  late Function updateEventTypes = (String newType) {

    if(!data.types.contains(newType)) {
      data.types.add(newType);
    }
    
    setState(() {
      wasChanged = true;
    });
  };

  late Function updateCurrentDate = (EventDate newDate) {
    setState(() {
      currentDate = newDate;  
    });
  };

  bool showEvent(Event event) {
      return (event.endTime == null && Time.isTimeBefore(event.startTime, Time.fromEventDate(currentDate)))
        || Time.sameDayAs(Time.fromEventDate(currentDate), event.startTime)
        || Time.sameDayAs(Time.fromEventDate(currentDate), event.endTime)
        || Time.isBetween(Time.fromEventDate(currentDate), event.startTime, event.endTime);
    }
}