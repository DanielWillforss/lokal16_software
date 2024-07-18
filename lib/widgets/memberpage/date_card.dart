import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/time/event_date.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/util/alerts.dart';
import 'package:lokal16_software/visual/style.dart';

class DateCard extends StatelessWidget implements PreferredSizeWidget{
  
  final EventDate date;
  final Function changeToDate;

  const DateCard({
    required this.date,  
    required this.changeToDate,
    super.key
  });

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () async{
              date.stepBackward();
              changeToDate(date);
            },
            child: const Text("<- Föregående", style: Style.headerText,),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              showDatePicker(
                context: context, 
                initialDate: DateTime.now(),
                firstDate: DateTime(2000), 
                lastDate: DateTime(2100),
              ).then((pickedTime) {
                if (pickedTime != null) {
                  EventDate date = EventDate.fromDateTime(pickedTime);
                  if(Time.isTimeBefore(Time.fromEventDate(date), Time.now(), strict: false)) {
                    changeToDate(date);
                  } else {
                    AlertHandeler.newAlert(context, Alerts.badDate);
                  }
                }
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Time.sameDayAs(Time.now(), Time.fromEventDate(date)) 
                  ? Style.blue 
                  : Style.pink, 
                width: 2
              )
            ),
            child: Text(date.toString(), style: Style.headerText,),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              date.stepForward();
              changeToDate(date);
            },
            child: Text("Nästa ->", 
              style: !Time.sameDayAs(Time.now(), Time.fromEventDate(date)) 
                ? Style.headerText
                : const TextStyle(
                  color: Colors.grey,
                ),
            ),
          ),
        ),
      ],
    );
  }
}