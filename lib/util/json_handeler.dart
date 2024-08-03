import 'dart:io';

import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:path_provider/path_provider.dart';


Future<File> _getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/data.json');
}

Future<void> writeData(DataNew data) async {
  final file = await _getLocalFile();
  await file.writeAsString(data.getJsonDataString());
}

Future<String> readData() async {
  final File file = await _getLocalFile();
  return await file.readAsString();
}

Future<File> _getBackupFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/backup.json');
}

Future<void> writeBackupData(DataNew data) async {
  final file = await _getBackupFile();
  await file.writeAsString(data.getJsonBackupDataString());
}

Future<String> readBackupData() async {
  final File file = await _getBackupFile();
  return await file.readAsString();
}
  
  