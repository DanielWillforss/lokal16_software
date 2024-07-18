import 'package:lokal16_software/classes/time/time.dart';

class EventTime implements Comparable<EventTime>{
  late int _hour;
  late int _minute;
  late final int _second;

  EventTime(this._hour, this._minute, this._second);

  int get hour => _hour;
  int get minute => _minute;
  int get second => _second;

  String toLabel() {
    return "${Time.numberAsString(hour)}:${Time.numberAsString(minute)}";
  }

  @override
  String toString() {
    return "${Time.numberAsString(hour)}:${Time.numberAsString(minute)}:${Time.numberAsString(second)}";
  }

  // Override == operator and hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute &&
          second == other.second;

  @override
  int get hashCode => 
    hour.hashCode ^
    minute.hashCode ^
    second.hashCode
  ;

  @override
  int compareTo(EventTime other) {
    if (hour != other.hour) {
      return hour.compareTo(other.hour);
    } else if (minute != other.minute) {
      return minute.compareTo(other.minute);
    } else {
      return second.compareTo(other.second);
    }
  }

  void incrementMinute() {
    _minute ++;
    if(minute > 59) {
      _minute = 0;
      _hour++;
      if(hour > 23) {
        _hour = 0;
      }
    }
  }
}