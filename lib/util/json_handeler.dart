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
  