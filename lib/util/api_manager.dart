import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/classes/data/api_data.dart';
import 'package:lokal16_software/util/data_util.dart';

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
      _getStringData('Names!A1:A'),
      _getStringData('EventTypes!A1:A'),
      _getAllEvents(),
    ];

    List<dynamic> data = await Future.wait(futures);

    return formatData({
      'names' : data[0],
      'eventTypes' : data[1],
      'eventList' : data[2],
    });
  }

  Future<void> updateSheetData(Data data) async {

    List<String> sheetNames = ['Names','EventTypes','EventList',];
    List<List<List<Object>>> cellValues = dataToCellValues(data);

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

  Future<List<List<Object>>> _getStringData(String path) async {
    String activityData = path;
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
}
