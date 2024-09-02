import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/classes/time/time.dart';

class GoogleSheetsApi {
  final _scopes = [sheets.SheetsApi.spreadsheetsScope];
  //final String _spreadsheetId = '1j1SATA9QvJCqgUstcpOWqOlaopH0x-0kQXGSnjDEVKk';
  final String _spreadsheetId = '1SE2d1UYV1nS8BaWgP8caS_GdF4BYHhdQ_Wg0jvO_8F4';
  late final String _jsonCredentials;

  GoogleSheetsApi();

  Future<void> setupCredentials() async {
    //_jsonCredentials = await rootBundle.loadString('assets/lokal16-software.json');
    _jsonCredentials = await rootBundle.loadString('assets/lokal16-software-official.json');
  }

  Future<ApiData> getAllData() async {
    List<Future> futures = [
      _getAllNames(),
      _getAllTypes(),
      _getAllEvents(),
    ];

    List<dynamic> data = await Future.wait(futures);
    return formatData({
      'names' : data[0],
      'types' : data[1],
      'events' : data[2],
    });
  }

  Future<void> updateSheetData(ApiData data) async {

    List<String> sheetNames = ['Names','EventTypes','EventList',];
    List<List<List<Object>>> cellValues = _dataToCellValues(data);

    var sheetsApi = await _getSheetsApi();
    for(int i = 0; i<3; i++) {

      var clearRange = sheetsApi.spreadsheets.values.clear(
        sheets.ClearValuesRequest(), _spreadsheetId, sheetNames[i]
      );
      await clearRange;
      
      var request = sheets.ValueRange(
        range: sheetNames[i],
        values: cellValues[i],
      );
      await sheetsApi.spreadsheets.values.update(
        request, _spreadsheetId, sheetNames[i], valueInputOption: 'RAW'
      );
    }
  }

  Future<sheets.SheetsApi> _getSheetsApi() async {
    var accountCredentials = ServiceAccountCredentials.fromJson(_jsonCredentials);
    var client = await clientViaServiceAccount(accountCredentials, _scopes);
    return sheets.SheetsApi(client);
  }

  Future<List<List<Object>>> _getAllNames() async {
    String activityData = 'Names!A1:D';
    List<List<Object>> data = await _getSheetData(activityData);
    
    return data;
  }

  Future<List<List<Object>>> _getAllTypes() async {
    String activityData = 'EventTypes!A1:A';
    List<List<Object>> data = await _getSheetData(activityData);
    return data;
  }

  Future<List<List<Object>>> _getAllEvents() async {
    String eventData = 'EventList!A1:J';
    List<List<Object>> data = await _getSheetData(eventData);
    return data;
  }
  
  Future<List<List<Object>>> _getSheetData(String sheetName) async {
    var sheetsApi = await _getSheetsApi();
    var response = await sheetsApi.spreadsheets.values.get(_spreadsheetId, sheetName);
    
    // Convert the nullable values to non-nullable
    List<List<Object>> data = response.values?.map((row) => row.map((value) => value ?? '').toList()).toList() ?? [];
    
    return data;
  }

  List<List<List<Object>>> _dataToCellValues(ApiData data) {
    return [
      _namesToData(data.names),
      _typesToData(data.types),
      _eventsToData(data.events),
    ];
  }

  List<List<Object>> _namesToData(Set<Name> names) {
    List<List<Object>> data = [];
    data.add([
      "FirstName",
      "LastName",
      "PersonalNumber",
      "Member"
    ]);
    for (Name name in names) {
      data.add([
        name.firstName,
        name.lastName,
        name.personalNumber,
        name.paidFee ?? "",
      ]);
    }
    return data;
  }

  List<List<Object>> _typesToData(Set<String> types) {
    List<List<Object>> data = [];
    data.add(["Types"]);
    for(String id in types) {
      data.add([id]);
    }
    return data;
  }

  List<List<Object>> _eventsToData(Set<Event> events) {
    List<List<Object>> data = [];
    data.add([
      "Id",
      "DateTimeStart",
      "DateStart",
      "TimeStart",
      "DateTimeEnd",
      "DateEnd",
      "TimeEnd",
      "Duration",
      "Member",
      "EventType"
    ]);
    for (Event event in events) {
      data.add([
        event.id.toString(),
        event.startTime.toString(),
        event.startTime.date.toString(),
        event.startTime.time.toString(),
        event.endTime == null ? "" : event.endTime.toString(),
        event.endTime == null ? "" : event.endTime!.date.toString(),
        event.endTime == null ? "" : event.endTime!.time.toString(),
        event.duration()?.toStringAsFixed(2).replaceAll('.', ',') ?? "",
        event.member,
        event.eventType,
      ]);
    }
    return data;
  }

  ApiData formatData(Map<String, dynamic> data) {
    Set<Name> names = _dataToNames(data['names']);
    Set<String> types = _dataToTypes(data['types']);
    Set<Event> events = _dataToEvents(data['events']);

    return ApiData(
      names: names,
      types: types,
      events: events,
    );
  }

  Set<Name> _dataToNames(List<List<Object>> data) {

    List<Object> title;
    try {
      title = data.removeAt(0);
    } catch (e) {
      throw const FormatException("Data is empty");
    }

    try {
      if(
        title[0].toString().isEmpty ||
        title[1].toString().isEmpty ||
        title[2].toString().isEmpty ||
        title[3].toString().isEmpty
      ) {
        throw Exception();
      }
    } catch (e) {
      throw const FormatException("Faulty Data");
    }

    Set<Name> dataList = {};
    for (var element in data) {
      if(element.toString().isNotEmpty && element.toString() != "[]") {
        dataList.add(Name(
          firstName: element[0] as String, 
          lastName: element[1] as String, 
          personalNumber: element[2] as String,
          paidFee: element.length > 3 ? int.tryParse(element[3] as String) : null,
        ));
      }
    }
    return dataList;
  }

  Set<String> _dataToTypes(List<List<Object>> data) {

    List<Object> title;
    try {
      title = data.removeAt(0);
    } catch (e) {
      throw const FormatException("Data is empty");
    }


    try {
      if(
        title[0].toString().isEmpty
      ) {
        throw Exception();
      }
    } catch (e) {
      throw const FormatException("Faulty Data");
    }

    Set<String> dataList = {};
    for (var element in data) {
      if(element.toString().isNotEmpty && element.toString() != "[]") {
        dataList.add(element[0] as String);
      }
    }
    return dataList;
  }

  Set<Event> _dataToEvents(List<List<Object>> data) {

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

    List<Object> title;
    try {
      title = data.removeAt(0);
    } catch (e) {
      throw const FormatException("Data is empty");
    }

    try {
      if(
        title[0].toString().isEmpty ||
        title[1].toString().isEmpty ||
        title[2].toString().isEmpty ||
        title[3].toString().isEmpty ||
        title[4].toString().isEmpty ||
        title[5].toString().isEmpty ||
        title[6].toString().isEmpty ||
        title[7].toString().isEmpty ||
        title[8].toString().isEmpty ||
        title[9].toString().isEmpty
      ) {
        throw Exception();
      }
    } catch (e) {
      throw const FormatException("Faulty Data");
    }


    Set<Event> dataList = {};
    for (var element in data) {
      if(element.toString().isNotEmpty && element.toString() != "[]") {
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

}

class ApiData {
  Set<Name> names;
  Set<String> types;
  Set<Event> events;

  ApiData({
    required this.names,
    required this.types,
    required this.events,
  });
}