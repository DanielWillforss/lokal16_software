
import 'package:lokal16_software/classes/changes.dart';
import 'package:lokal16_software/classes/event.dart';

class MemberData {
  String name;
  Set<String> types;
  Set<Event> events;
  Changes changes = Changes();

  MemberData({
    required this.name,
    required this.types,
    required this.events,
  });
}