import 'package:lokal16_software/classes/event.dart';
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

Map<String, Set<Event>> getSplitByPerson(Set<Event> events) {
  Map<String, Set<Event>> idMap = {};
  for(Event event in events) {
    String person = event.member;
    Set<Event> list = idMap.putIfAbsent(person, () => {});
    list.add(event);
  }
  return idMap;
}