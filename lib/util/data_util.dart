import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/classes/time/time.dart';

Set<Event> findCollitions(Set<Event> events) {
  Map<String, Set<Event>> idMap = getSplitByPerson(events);
  Set<Event> overlapping = {};
  idMap.forEach((name, subSet) {
    List<Event> subList = subSet.toList();
    int length = subList.length;
    for(int i = 0; i<length-1; i++) {
      Event event = subList[i];
      if (Time.isTimeBefore(subList[i+1].startTime, event.endTime)) {
        overlapping.add(event);
        overlapping.add(subList[i+1]);
        continue;
      }
      DateTime dateTime1 = event.endTime!.toDateTime();
      DateTime dateTime2 = event.startTime.toDateTime();
      Duration difference = dateTime1.difference(dateTime2);
      if(difference == Duration.zero) {
        overlapping.add(event);
      }
    }
  });
  
  return overlapping;
}

Set<Event> findUnreachable(Set<Event> events, Set<Name> names) {
  Map<String, Set<Event>> idMap = getSplitByPerson(events);
  Set<String> namesAsKey = names.map((name) => name.toFullString()).toSet();
  Set<Event> unreachable = {};
  idMap.forEach((name, subSet) {
    if(!namesAsKey.contains(name)) {
      unreachable.addAll(subSet);
    }
  });
  
  return unreachable;
}

Map<String, Set<Event>> getSplitByPerson(Set<Event> events) {
  Map<String, Set<Event>> idMap = {};
  for(Event event in events) {
    String person = event.member;
    Set<Event> list = idMap.putIfAbsent(person, () => {});
    list.add(event);
  }
  return idMap;
}

Map<String, Set<Event>> getSplitByType(Set<Event> events) {
  Map<String, Set<Event>> idMap = {};
  for(Event event in events) {
    String type = event.eventType;
    Set<Event> list = idMap.putIfAbsent(type, () => {});
    list.add(event);
  }
  return idMap;
}

double totalDuration(Set<Event> events) {
  double sum = 0;
  for (var event in events) {
    sum += event.duration() ?? 0;
  }
  return sum;
}

bool isCheckedIn(Set<Event> eventList) {
  for(Event event in eventList) {
    if(Time.isBetween(Time.now(), event.startTime, event.endTime)) {
      return true;
    }
  }
  return false;
}