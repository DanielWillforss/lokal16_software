import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/api_data.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/util/data_util.dart';

class Data {
  late List<String> names;
  late List<String> eventTypes;
  late List<Event> eventList;
  Set<int> deletedEvents = {};
  Set<Event> overlapping = {};

  Data(Map<String, dynamic> dataMap) {

    try {
      names = dataMap['names'].cast<String>();
      eventTypes = dataMap['activities'].cast<String>();
      eventList = dataMap['events'].cast<Event>();
      deletedEvents = dataMap['deleted'].cast<int>().toSet();
    } catch (e) {
      rethrow;
    }
  }

  Data.empty() {
    names = [];
    eventTypes = [];
    eventList = [];
  }

  Data deepCopy() {
    Data newData = Data.empty();
    newData.names = names.toList();
    newData.eventTypes = eventTypes.toList();
    newData.eventList = eventList.toList();
    newData.deletedEvents = deletedEvents.toSet();
    newData.overlapping = overlapping.toSet();
    return newData;
  }

  void sortData() {
    names.sort();
    eventTypes.sort();
    eventList.sort();
  }

  Map<String, List<Event>> getSplitByPerson() {
    Map<String, List<Event>> idMap = {};
    for(Event event in eventList) {
      String person = event.member;
      List<Event> list = idMap.putIfAbsent(person, () => []);
      list.add(event);
    }
    return idMap;
  }

  bool mergeWithNewData(ApiData newData) {
    names = newData.names;
    
    List<String> mergedEventTypes = [...eventTypes, ...newData.eventTypes];
    eventTypes = mergedEventTypes.toSet().toList();
    
    List<Event> mergedEvents = newData.eventList;
    mergedEvents.removeWhere((event) => deletedEvents.contains(event.id));
    int largestIndex = 1;
    for(Event event in mergedEvents) {
      if(event.id != null && event.id! >= largestIndex) {
        largestIndex = event.id! + 1;
      }
    }
    for(Event event in eventList) {
      if(event.id == null) {
        event.id = largestIndex;
        largestIndex++;
        mergedEvents.add(event);
      } else if (event.isChanged) {
        int index = mergedEvents.indexWhere((oldEvent) => oldEvent.id == event.id);
        event.isChanged = false;
        mergedEvents[index] = event;
      }
    }
    eventList = mergedEvents;
    sortData();
    return !findCollitions();
  }

  bool findCollitions() {
    Map<String, List<Event>> idMap = getSplitByPerson();
    overlapping = {};
    idMap.forEach((name, subList) {
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
    
    return overlapping.isNotEmpty;
  }

  Future<void> mergeWithPageReturn(Map<String, dynamic> returnData, String name, BuildContext context) async {
    Map<String, List<Event>> splitByPerson = getSplitByPerson();
    splitByPerson.update(name, (value) => returnData['eventList'], ifAbsent: () => returnData['eventList']);
      
    eventList = _mergeSplitMap(splitByPerson);
    deletedEvents.addAll(returnData['deleted']);
    
    if(eventTypes != returnData['eventTypes']) {
      eventTypes = returnData['eventTypes'];
      await adminSyncData(this, context);
    }
  }

  static List<Event> _mergeSplitMap(Map<String, List<Event>> splitMap) {
    List<Event> list = [];
    splitMap.forEach((key, value) {
      list.addAll(value);
    });
    return list;
  }
}