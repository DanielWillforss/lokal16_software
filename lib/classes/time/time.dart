import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/time/event_date.dart';
import 'package:lokal16_software/classes/time/event_time.dart';

class Time implements Comparable<Time>{

  late EventDate _date;
  late EventTime _time;

  Time({
    required year,
    required month,
    required day,
    required hour,
    required minute,
    required second,
  }) {
    _date = EventDate(year, month, day);
    _time = EventTime(hour, minute, second);
  }

  EventDate get date => _date;
  EventTime get time => _time;

  Time.fromString(String string) {
    var symbols = RegExp(r'[- :]');
    List<String> parts = string.split(symbols);

    _date = EventDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    _time = EventTime(
      int.parse(parts[3]),
      int.parse(parts[4]),
      int.parse(parts[5]),
    );
  }

  Time.fromEventDate(EventDate eventDate) {
    _date = eventDate;
    _time = EventTime(
      0,
      0,
      0,
    );
  }

  Time.now() {
    DateTime dateTime = DateTime.now();
    _date = EventDate(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    _time = EventTime(
      dateTime.hour,
      dateTime.minute,
      0,
    );
  }

  Time.nowOtherDate(EventDate eventDate) {
    DateTime dateTime = DateTime.now();
    _date = EventDate(
      eventDate.year, 
      eventDate.month, 
      eventDate.day
    );

    _time = EventTime(
      dateTime.hour,
      dateTime.minute,
      0,
    );
  }

  void incrementMinute() {
    time.incrementMinute();
    if(time.minute == 0 && time.hour == 0) {
      date.stepForward();
    }
  }

  Time deepCopy() {
    return Time(
      year: date.year, 
      month: date.month, 
      day: date.day, 
      hour: time.hour, 
      minute: time.minute, 
      second: time.second,
    );
  }

  Time.mergeTimeOfDay(Time oldTime, TimeOfDay timeOfDay) {
    _date = EventDate(
      oldTime.date.year,
      oldTime.date.month,
      oldTime.date.day,
    );
    _time = EventTime(
      timeOfDay.hour,
      timeOfDay.minute,
      oldTime.time.second,
    );
  }

  Time.mergeDateTime(Time oldTime, DateTime dateTime) {
    _date = EventDate(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    _time = oldTime.time;
  }

  String toButtonLabel() {
    return "${date.toLabel()} ${time.toLabel()}";
  }

  DateTime toDateTime() {
    return DateTime(
      date.year, 
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second
    );
  }

  static String numberAsString(int date) {
    if(date >= 10) {
      return date.toString();
    } else {
      return "0${date.toString()}";
    }
  }

  static bool isBetween(Time time, Time? t1, Time? t2) {
    return Time.isTimeBefore(t1, time, strict: false) && Time.isTimeBefore(time, t2, strict: true);
  }

  static bool isTimeBefore(Time? t1, Time? t2, {bool strict = true}) {

    if(t1 == null) {
      return false;
    } else if(t2 == null) {
      return true;
    } else if(t1.date.year<t2.date.year) {
      return true;
    } else if (t1.date.year>t2.date.year) {
      return false;
    } else if(t1.date.month<t2.date.month) {
      return true;
    } else if (t1.date.month>t2.date.month) {
      return false;
    } else if(t1.date.day<t2.date.day) {
      return true;
    } else if (t1.date.day>t2.date.day) {
      return false;
    } else if(t1.time.hour<t2.time.hour) {
      return true;
    } else if (t1.time.hour>t2.time.hour) {
      return false;
    } else if(t1.time.minute<t2.time.minute) {
      return true;
    } else if (t1.time.minute>t2.time.minute) {
      return false;
    } else {
      return !strict;
    }
  }

  static bool sameDayAs(Time? t1, Time? t2) {
    if(t1 == null || t2 == null) {
      return false;
    }
    
    if(t1.date == t2.date) {
      return true;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return "${date.toString()} ${time.toString()}";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Time && runtimeType == other.runtimeType &&
          date == other.date && time == other.time ;

  @override
  int get hashCode => date.hashCode ^ time.hashCode;

  @override
  int compareTo(Time other) {
    if (date != other.date) {
      return date.compareTo(other.date);
    } else {
      return time.compareTo(other.time);
    }
  }
}

