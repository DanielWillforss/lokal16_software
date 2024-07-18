import 'package:lokal16_software/classes/time/time.dart';

class Event implements Comparable<Event>{
  int? id;
  late String member;
  late String eventType;
  late Time startTime;
  late Time? endTime;
  late bool isChanged;
  

  Event({
    required this.member,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    this.id,
    this.isChanged = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'member' : member,
      'eventType' : eventType,
      'startTime' : startTime.toString(),
      'endTime' : endTime.toString(),
      'id' : id,
      'isChanged' : isChanged,
    };
  }

  String? duration() {
    if(endTime == null) {
      return null;
    }

    DateTime dateTime1 = endTime!.toDateTime();
    DateTime dateTime2 = startTime.toDateTime();
    Duration difference = dateTime1.difference(dateTime2);
    int differenceInMinutes = difference.inMinutes;

    double fraction = differenceInMinutes / 60;
    return fraction.toStringAsFixed(2);
  }

  @override
  String toString() {
    return "($member, $eventType, $startTime, $endTime)";
  }

  // Override == operator and hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          member == other.member &&
          startTime == other.startTime &&
          id == other.id;

  @override
  int get hashCode => member.hashCode ^ startTime.hashCode ^ id.hashCode;

  @override
  int compareTo(Event other) {
    if (startTime != other.startTime) {
      return startTime.compareTo(other.startTime);
    } else if(endTime == null && other.endTime == null) {
      return 0;
    } else if(endTime == null) {
      return -1;
    } else if(other.endTime == null) {
      return 1;
    } else if (endTime != other.endTime) {
      return endTime!.compareTo(other.endTime!);
    } else {
      return member.compareTo(other.member);
    }
  }

  static bool isCheckedIn(List<Event> eventList) {
    for(Event event in eventList) {
      if(Time.isBetween(Time.now(), event.startTime, event.endTime)) {
        return true;
      }
    }
    return false;
  }
}