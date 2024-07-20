// ignore_for_file: use_build_context_synchronously

import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/time/time.dart';

//Future<bool> syncData(Data data, BuildContext context) async {
//  bool connectedOnline = true;
//  
//  ApiData? mapData;
//  bool gotOnlineData = false;
//  GoogleSheetsApi api = GoogleSheetsApi();
//  try { //Try getting online data
//    await api.setupCredentials();
//    mapData = await api.getAllData();
//    gotOnlineData = true;
//  } catch (e) {
//    await AlertHandeler.newAlert(context, Alerts.apiError(e));
//    connectedOnline = false;
//    //Change to offline
//  }
//  
//  if(gotOnlineData) {
//    bool withoutCollitions = data.mergeWithNewData(mapData!);
//    if(!withoutCollitions) {
//      await AlertHandeler.newAlert(context, Alerts.collitions);
//    }
//    try { //Try upload data
//      await api.updateSheetData(data);
//    } catch (e) {
//      await AlertHandeler.newAlert(context, Alerts.apiError(e));
//      connectedOnline = false;
//    }
//  }
//  
//
//  try { //Try save locally
//    await writeData(data);
//  } catch (e) {
//    if (e is MissingPluginException) {
//      //await AlertHandeler.newAlert(context, Alerts.wrongPlatform);
//      //Do nothing
//    } else {
//      await AlertHandeler.newAlert(context, Alerts.jsonError(e));
//    }
//  }
//  
//  return connectedOnline;
//}

//Future<bool> adminSyncData(Data data, BuildContext context) async {
//  bool connectedOnline = true;
//
//  GoogleSheetsApi api = GoogleSheetsApi();
//  try { //Try getting online data
//    await api.setupCredentials();
//  } catch (e) {
//    await AlertHandeler.newAlert(context, Alerts.apiError(e));
//    connectedOnline = false;
//  }
//  
//  try { //Try upload data
//    await api.updateSheetData(data);
//  } catch (e) {
//    await AlertHandeler.newAlert(context, Alerts.apiError(e));
//    connectedOnline = false;
//  }
//  
//
//  try { //Try save locally
//    await writeData(data);
//  } catch (e) {
//    if (e is MissingPluginException) {
//    } else {
//      await AlertHandeler.newAlert(context, Alerts.jsonError(e));
//    }
//  }
//  
//  return connectedOnline;
//}





//Map<String, dynamic> defaultData() {
//  return {
//    'names' : <String>[],
//    'activities' : <String>[],
//    'events' : <Event>[],
//    'deleted' : <int>[],
//  };
//}

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