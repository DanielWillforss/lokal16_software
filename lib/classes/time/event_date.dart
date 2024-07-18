import 'package:lokal16_software/classes/time/time.dart';

class EventDate implements Comparable<EventDate>{
  late int _year;
  late int _month;
  late int _day;

  EventDate(this._year, this._month, this._day);

  int get year => _year;
  int get month => _month;
  int get day => _day;

  EventDate.fromDateTime(DateTime time) {
    _year = time.year;
    _month = time.month;
    _day = time.day;
  }

  EventDate.now() {
    DateTime dateTime = DateTime.now();
    _year = dateTime.year;
    _month = dateTime.month;
    _day = dateTime.day;
  }

  String toLabel() {
    return "${Time.numberAsString(day)}/${Time.numberAsString(month)}";
  }

  void stepForward() {
    _day++;
    int maxDaysInMonth = _daysInMonth(year, month);
    if (day > maxDaysInMonth) {
      _day = 1;
      _month++;
      if (month > 12) {
        _month = 1;
        _year++;
      }
    }
    if(Time.isTimeBefore( Time.now(), Time.fromEventDate(this), strict: false)) {
      stepBackward();
    }
  }

  void stepBackward() {
    _day--;
    if (day < 1) {
      _month--;
      if (month < 1) {
        _month = 12;
        _year--;
      }
      _day = _daysInMonth(year, month);
    }
  }

  int _daysInMonth(int year, int month) {
    switch (month) {
      case 1: // January
      case 3: // March
      case 5: // May
      case 7: // July
      case 8: // August
      case 10: // October
      case 12: // December
        return 31;
      case 4: // April
      case 6: // June
      case 9: // September
      case 11: // November
        return 30;
      case 2: // February
        // Check for leap year
        if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
          return 29; // Leap year
        } else {
          return 28; // Non-leap year
        }
      default:
        throw Exception("Invalid month");
    }
  }

  @override
  String toString() {
    return "$year-${Time.numberAsString(month)}-${Time.numberAsString(day)}";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => 
    year.hashCode ^
    month.hashCode ^
    day.hashCode
  ;

  @override
  int compareTo(EventDate other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    } else if (month != other.month) {
      return month.compareTo(other.month);
    } else {
      return day.compareTo(other.day);
    }
  }
}