import 'dart:convert';
import 'dart:io';

import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:path_provider/path_provider.dart';


Future<File> _getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/data.json');
}

Future<void> writeData(Data data) async {
  final file = await _getLocalFile();
  Map<String, dynamic> jsonData = {};

  jsonData['names'] = data.names;
  jsonData['activities'] = data.eventTypes;
  jsonData['events'] = data.eventList.map((item) => item.toJson()).toList();
  jsonData['deleted'] = data.deletedEvents.toList();

  String jsonString = json.encode(jsonData);
  await file.writeAsString(jsonString);
}

Future<Data> readData() async {
  
  final File file = await _getLocalFile();
  String jsonString = await file.readAsString();
  Map<String, dynamic> jsonData = json.decode(jsonString);

  return Data({
    'names' : jsonData['names'],
    'activities' : jsonData['activities'],
    'events' : jsonData['events'].map((item) {
      return Event(
        member: item['member'],
        eventType: item['eventType'],
        startTime: Time.fromString(item['startTime']),
        endTime: item['endTime']  == "null" ? null : Time.fromString(item['endTime']),
        id: item['id'],
        isChanged: item['isChanged'],
      );
    }).toList(),
    'deleted' : jsonData['deleted'].toList(),
  });
}
  