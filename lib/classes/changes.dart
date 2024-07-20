import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/name.dart';
import 'package:lokal16_software/classes/time/time.dart';

class Changes {
  Set<Name> _addedNames = {};
  Set<String> _addedTypes = {};
  Set<Event> _addedEvents = {};
  Set<Name> _removedNames = {};
  Set<String> _removedTypes = {};
  Set<Event> _removedEvents = {};

  Set<Name> get addedNames => _addedNames;
  Set<String> get addedTypes => _addedTypes;
  Set<Event> get addedEvents => _addedEvents;
  Set<Name> get removedNames => _removedNames;
  Set<String> get removedTypes => _removedTypes;
  Set<Event> get removedEvents => _removedEvents;

  void addName(Name name) {
    _addedNames.add(name);
  }

  void addType(String type) {
    _addedTypes.add(type);
  }

  void addEvent(Event event) {
    _addedEvents.add(event);
  }

  void removeName(Name name) {
    if(!_addedNames.remove(name)) {
      _removedNames.add(name);
    }
  }

  void removeType(String type) {
    if(!_addedTypes.remove(type)) {
      _removedTypes.add(type);
    }
  }

  void removeEvent(Event event) {
    if(!_addedEvents.remove(event)) {
      _removedEvents.add(event);
    }
  }

  void mergeChanges(Changes changes) {
    _addedNames.addAll(changes.addedNames);
    _addedTypes.addAll(changes.addedTypes);
    _addedEvents.addAll(changes.addedEvents);
    _removedNames.removeAll(changes.removedNames);
    _removedTypes.removeAll(changes.removedTypes);
    _removedEvents.removeAll(changes.removedEvents);
  }

  Map<String, dynamic> toJson() {
    return {
      'addedNames' : _addedNames.map((item) => item.toJson()).toList(),
      'addedTypes' : _addedTypes.toList(),
      'addedEvents' : _addedEvents.map((item) => item.toJson()).toList(),
      'removedNames' : _removedNames.map((item) => item.toJson()).toList(),
      'removedTypes' : _removedTypes.toList(),
      'removedEvents' : _removedEvents.map((item) => item.toJson()).toList(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _addedNames = json['addedNames'].map((item) {
      return Name(
        firstName: item['firstName'],
        lastName: item['lastName'],
        personalNumber: item['personalNumber'],
        member: item['member'],
      );
    }).toSet;
    _addedTypes = json['addedTypes'];
    _addedEvents = json['addedEvents'].map((item) {
      return Event(
        member: item['member'],
        eventType: item['eventType'],
        startTime: Time.fromString(item['startTime']),
        endTime: item['endTime']  == "null" ? null : Time.fromString(item['endTime']),
        id: item['id'],
        isChanged: item['isChanged'],
      );
    }).toSet();
    _removedNames = json['removedNames'].map((item) {
      return Name(
        firstName: item['firstName'],
        lastName: item['lastName'],
        personalNumber: item['personalNumber'],
        member: item['member'],
      );
    }).toSet();
    _removedTypes = json['removedTypes'];
    _removedEvents = json['removedEvents'].map((item) {
      return Event(
        member: item['member'],
        eventType: item['eventType'],
        startTime: Time.fromString(item['startTime']),
        endTime: item['endTime']  == "null" ? null : Time.fromString(item['endTime']),
        id: item['id'],
        isChanged: item['isChanged'],
      );
    }).toSet();
  }
}