import 'package:lokal16_software/classes/event.dart';

class ApiData {
  List<String> names;
  List<String> eventTypes;
  List<Event> eventList;

  ApiData({
    required this.names,
    required this.eventTypes,
    required this.eventList,
  });
}