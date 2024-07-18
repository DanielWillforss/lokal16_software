// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/classes/data/api_data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/util/alerts.dart';
import 'package:lokal16_software/util/api_manager.dart';
import 'package:lokal16_software/util/json_handeler.dart';

Future<bool> syncData(Data data, BuildContext context, {bool isOnline = true}) async {
  bool connectedOnline = isOnline;
  if(isOnline) {
    ApiData? mapData;
    bool gotOnlineData = false;
    GoogleSheetsApi api = GoogleSheetsApi();
    try { //Try getting online data
      await api.setupCredentials();
      mapData = await api.getAllData();
      gotOnlineData = true;
    } catch (e) {
      await AlertHandeler.newAlert(context, Alerts.apiError(e));
      connectedOnline = false;
      //Change to offline
    }
    
    if(gotOnlineData) {
      bool withoutCollitions = data.mergeWithNewData(mapData!);
      if(!withoutCollitions) {
        await AlertHandeler.newAlert(context, Alerts.collitions);
      }
      try { //Try upload data
        await api.updateSheetData(data);
      } catch (e) {
        await AlertHandeler.newAlert(context, Alerts.apiError(e));
        connectedOnline = false;
      }
    }
  }

  try { //Try save locally
    await writeData(data);
  } catch (e) {
    if (e is MissingPluginException) {
      //await AlertHandeler.newAlert(context, Alerts.wrongPlatform);
      //Do nothing
    } else {
      await AlertHandeler.newAlert(context, Alerts.jsonError(e));
    }
  }
  
  return connectedOnline;
}

Future<bool> adminSyncData(Data data, BuildContext context) async {
  bool connectedOnline = true;

  GoogleSheetsApi api = GoogleSheetsApi();
  try { //Try getting online data
    await api.setupCredentials();
  } catch (e) {
    await AlertHandeler.newAlert(context, Alerts.apiError(e));
    connectedOnline = false;
  }
  
  try { //Try upload data
    await api.updateSheetData(data);
  } catch (e) {
    await AlertHandeler.newAlert(context, Alerts.apiError(e));
    connectedOnline = false;
  }
  

  try { //Try save locally
    await writeData(data);
  } catch (e) {
    if (e is MissingPluginException) {
    } else {
      await AlertHandeler.newAlert(context, Alerts.jsonError(e));
    }
  }
  
  return connectedOnline;
}

ApiData formatData(Map<String, dynamic> data) {
  List<String> namesList = _dataToStringList(data['names']);
  List<String> eventTypes = _dataToStringList(data['eventTypes']);
  List<Event> eventList = _dataToEvent(data['eventList']);

  return ApiData(
    names: namesList,
    eventTypes: eventTypes,
    eventList: eventList,
  );
}

List<String> _dataToStringList(List<List<Object>> data) {
  List<String> dataList = [];
  for (var element in data) {
    if(element.toString().isNotEmpty) {
      dataList.add(element[0] as String);
    }
  }
  return dataList;
}

List<Event> _dataToEvent(List<List<Object>> data) {

  //id - needed
  //start - needed
  //startdate
  //startTime
  //end - needed
  //endDate
  //endTime
  //period
  //person - needed
  //aktivitet - needed


  List<Event> dataList = [];
  for (var element in data) {
    if(element.toString().isNotEmpty) {
      dataList.add(Event(
        member: element[8] as String, 
        eventType: element[9] as String, 
        startTime: Time.fromString(element[1].toString()),
        endTime: element[4].toString().isNotEmpty ? Time.fromString(element[4].toString()) : null, 
        id: element[0] == "null" ? null : int.parse(element[0] as String),
      ));
    }
  }
  return dataList;
}

List<List<List<Object>>> dataToCellValues(Data data) {
  return [
    _stringListToData(data.names),
    _stringListToData(data.eventTypes),
    _eventToData(data.eventList),
  ];
}

List<List<Object>> _stringListToData(List<String> stringList) {
  List<List<Object>> data = [];
  for(String id in stringList) {
    data.add([id]);
  }
  return data;
}

List<List<Object>> _eventToData(List<Event> eventList) {
  List<List<Object>> data = [];
  for (Event event in eventList) {
    data.add([
      event.id.toString(),
      event.startTime.toString(),
      event.startTime.date.toString(),
      event.startTime.time.toString(),
      event.endTime == null ? "" : event.endTime.toString(),
      event.endTime == null ? "" : event.endTime!.date.toString(),
      event.endTime == null ? "" : event.endTime!.time.toString(),
      event.duration() ?? "",
      event.member,
      event.eventType,
    ]);
  }
  return data;
}

Map<String, dynamic> defaultData() {
  return {
    'names' : <String>[],
    'activities' : <String>[],
    'events' : <Event>[],
    'deleted' : <int>[],
  };
}