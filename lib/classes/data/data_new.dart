// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lokal16_software/classes/changes.dart';
import 'package:lokal16_software/classes/data/admin_data.dart';
import 'package:lokal16_software/classes/data/member_data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/util/alerts.dart';
import 'package:lokal16_software/util/api_manager.dart';
import 'package:lokal16_software/util/data_util.dart';
import 'package:lokal16_software/util/json_handeler.dart';

class DataNew {
  Set<Name> _names = {};
  Set<String> _types = {};
  Set<Event> _events = {};

  Changes changes = Changes();
  Set<Event> overlapping = {};

  AdminData getAdminData() {
    return AdminData(names: _names.toSet(), types: _types.toSet());
  }

  MemberData getMemberData(Name name) {
    return MemberData(
      name: name,
      types: _types.toSet(),
      events: getSplitByPerson(_events)[name.toFullString()] ?? {},
      allEvents: _events.toSet(),
    );
  }

  Map<String, Set<Event>> getSplitByName() {
    return getSplitByPerson(_events);
  }

  List<Name> getNamesSortedByCheckin() {
    Map<String, Set<Event>> eventsByperson = getSplitByPerson(_events);
    List<Name> allNames = _getActiveMembersToList();
    allNames.sort((a, b) {
      
      Set<Event> eventsA = eventsByperson[a.toFullString()] ?? {};
      Set<Event> eventsB = eventsByperson[b.toFullString()] ?? {};
      bool checkedInA = isCheckedIn(eventsA);
      bool checkedInB = isCheckedIn(eventsB);
      if(checkedInA && !checkedInB) {
        return -1;
      } else if(checkedInB && !checkedInA) {
        return 1;
      }
      
      int totalDurationA = totalDuration(eventsA).round();
      int totalDurationB = totalDuration(eventsB).round();
      if(totalDurationA != totalDurationB) {
        return totalDurationB - totalDurationA;
      }
      
      return a.compareTo(b);
    });
    return allNames;
  }

  List<Name> getNamesSortedByName() {
    List<Name> allNames = _getActiveMembersToList();
    allNames.sort();
    return allNames;
  }

  List<Name> _getActiveMembersToList() {
    List<Name> names = _names.toList();
    names.removeWhere((name) {
      return name.paidFee == null || name.paidFee! < 200;
    });
    return names;
  }

  Future<bool> initData(BuildContext context) async {
    try {
      String jsonString = await readData();
      Map<String, dynamic> jsonData = json.decode(jsonString);

      _names = jsonData['names'].map((item) {
        return Name(
          firstName: item['firstName'],
          lastName: item['lastName'],
          personalNumber: item['personalNumber'],
          paidFee: item['paidFee'],
        );
      }).toSet;
      _types = jsonData['activities'];
      _events = jsonData['events'].map((item) {
        return Event(
          member: item['member'],
          eventType: item['eventType'],
          startTime: Time.fromString(item['startTime']),
          endTime: item['endTime']  == "null" ? null : Time.fromString(item['endTime']),
          id: item['id'],
        );
      }).toSet();

      changes.fromJson(jsonData['changes']);
      checkForTwin();

      return true;
    } catch (e) {
      if(e is PathNotFoundException) {
        await AlertHandeler.newAlert(context, Alerts.noPath);
      } else if (e is MissingPluginException) {
        await AlertHandeler.newAlert(context, Alerts.wrongPlatform);
      } else {
        await AlertHandeler.newAlert(context, Alerts.jsonError(e));
      }
      return false;
    } 
  }

  void mergeChanges(Changes otherChanges) {

    _names.removeAll(otherChanges.removedNames);
    _names.addAll(otherChanges.addedNames);
    _types.removeAll(otherChanges.removedTypes);
    _types.addAll(otherChanges.addedTypes);
    _events.removeAll(otherChanges.removedEvents);
    _events.addAll(otherChanges.addedEvents);

    changes.mergeChanges(otherChanges);
    checkForTwin();
  }

  Future<bool> uploadData(BuildContext context) async {
    bool connectedOnline = true;

    ApiData? mapData;
    bool gotOnlineData;
    GoogleSheetsApi api = GoogleSheetsApi();
    try { //Try getting online data
      await api.setupCredentials();
      mapData = await api.getAllData();
      gotOnlineData = true;
    } catch (e) {
      await AlertHandeler.newAlert(context, Alerts.apiError(e));
      connectedOnline = false;
      gotOnlineData = false;
    }

    if(gotOnlineData) {
      bool withoutCollitions = _mergeWithNewData(mapData!);
      if(!withoutCollitions) {
        await AlertHandeler.newAlert(context, Alerts.collitions);
      }
      try { //Try upload data
        await api.updateSheetData(
          ApiData(
            names: _names, 
            types: _types, 
            events: _events
          )
        );
      } catch (e) {
        await AlertHandeler.newAlert(context, Alerts.apiError(e));
        connectedOnline = false;
      }
    }

    try { //Try save locally
      await writeData(this);
    } catch (e) {
      if (e is MissingPluginException) {
        //await AlertHandeler.newAlert(context, Alerts.wrongPlatform);
        //Do nothing
      } else {
        await AlertHandeler.newAlert(context, Alerts.jsonError(e));
      }
    }

    checkForTwin();
    return connectedOnline;
  }

  bool _mergeWithNewData(ApiData newData) {

    newData.names.addAll(changes.addedNames);
    newData.names.removeAll(changes.removedNames);

    newData.types.addAll(changes.addedTypes);
    newData.types.removeAll(changes.removedTypes);

    newData.events.removeAll(changes.removedEvents);
    int largestIndex = 1;
    for(Event event in newData.events) {
      if(event.id != null && event.id! >= largestIndex) {
        largestIndex = event.id! + 1;
      }
    }
    for(Event event in changes.addedEvents) {
      event.id = largestIndex;
      largestIndex++;
      newData.events.add(event);
    }

    _names = newData.names;
    _types = newData.types;
    _events = newData.events;
    changes = Changes();
    //sortData();
    overlapping = findCollitions(_events);
    return overlapping.isEmpty;
  }

  bool findOverlap() {
    overlapping = findCollitions(_events);
    return overlapping.isNotEmpty;
  }

  Set<Event> getUnreachable() {
    return findUnreachable(_events, _names);
  }

  String getJsonDataString () {
    Map<String, dynamic> jsonData = {};

    jsonData['names'] = _names.map((item) => item.toJson()).toList();
    jsonData['types'] = _types.toList();
    jsonData['events'] = _events.map((item) => item.toJson()).toList();
    jsonData['changes'] = changes.toJson();
    return json.encode(jsonData);
  }

  void checkForTwin() {
    Set<String> printName = {};
    for (var name in _names) {
      int oldLength = printName.length;
      String asString = name.toString();
      printName.add(asString);
      if(printName.length == oldLength) {
        printName.remove(asString);
        Iterable<Name> twins = _names.where((name) => name.toString() == asString);
        for (var twin in twins) {
          twin.hasTwin = true;
        }
      }
    }
  }
}