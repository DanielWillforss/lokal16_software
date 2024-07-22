
import 'package:lokal16_software/classes/changes.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/classes/time/event_date.dart';

class MemberData {
  late Name name;
  late Set<String> types;
  late Set<Event> events;
  late Set<Event> allEvents;
  Changes changes = Changes();
  EventDate currentDate = EventDate.now();

  MemberData({
    required this.name,
    required this.types,
    required this.events,
    required this.allEvents,
  });

  MemberData.empty() {
    name = Name(
      firstName: "",
      lastName: "",
      personalNumber: "",
      paidFee: null
    );
    types = {};
    events = {};
    allEvents = {};
  }

  //List<String> getEventsSplitByType() {
  //  return getSplitByType(events);
  //}
//
  //bool typeIsCheckedin(String type) {
  //  Map<String, Set<Event>> eventsByType = getSplitByType(events);
  //  if(isCheckedIn(eventsByType[type] ?? {})) {
  //    return true;
  //  }
  //  return false;
  //}

  bool addEvent(Event event) {
    int length = events.length;
    events.add(event);
    if(events.length == length) {
      return false;
    }
    allEvents.add(event);
    changes.addEvent(event);
    return true;
  }

  void removeEvent(Event event) {
    changes.removeEvent(event);
    events.remove(event);
    allEvents.remove(event);
  }

  void addType(String type) {
    changes.addType(type);
    types.add(type);
  }
}