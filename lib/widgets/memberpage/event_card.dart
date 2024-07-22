// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/member_data.dart';
import 'package:lokal16_software/classes/event.dart';
import 'package:lokal16_software/classes/time/time.dart';
import 'package:lokal16_software/util/data_util.dart';
import 'package:lokal16_software/visual/style.dart';

class EventCard extends StatefulWidget {

  final MemberData data;
  final Function updateData;
  final bool deleting;
  final Event? event;
  final Event? previousEvent;
  final Event? nextEvent;

  const EventCard({
    required this.data,
    required this.updateData,
    required this.deleting,
    required this.event, 
    required this.previousEvent,
    required this.nextEvent,
    super.key
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: widget.event != null 
        ? [ //Event not null
          Expanded(
            flex: 2,
            child: _timeViewer(true),
          ),
          Expanded(
            flex: 4,
            child: ElevatedButton(
              onPressed: () {
                _showEventSelectionDialog(context).then((result) {
                  if (result != null) {
                    widget.data.removeEvent(widget.event!);
                    widget.event!.eventType = result;
                    widget.data.addEvent(widget.event!);
                    widget.updateData();
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
                backgroundColor: Style.green,
              ),
              child: Text(
                widget.event!.eventType, 
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: widget.event!.endTime != null 
            ? _timeViewer(false) //Endtime in not null
            : ElevatedButton( //Endtime is null
              onPressed: () {
                _checkout(widget.event!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Style.blue,
              ),
              child: Text(widget.event!.endTime == null ? "Checka ut" : widget.event!.endTime!.toButtonLabel()),
            ),
          ),
          !widget.deleting 
          ? Container() 
          : Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () async {
                bool? confirmation = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Radera händelse"),
                      content: const Text("Är du säker att du vill radera denna händelse?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Return 'Option 1' when pressed
                          },
                          child: const Text("Bekräfta"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Return 'Option 1' when pressed
                          },
                          child: const Text("Avbryt"),
                        ),
                      ],
                    );
                  }
                );
                if(confirmation == true) {
                  widget.data.removeEvent(widget.event!);
                  widget.updateData();
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.white,),
              color: Colors.black,
            )
          )
        ] 
        : [ //event is null
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _addNewEvent();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Style.yellow,
              ),
              child: const Text("Ny Händelse"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeViewer(bool isStartTime) {
    Time timeToView = isStartTime ? widget.event!.startTime : widget.event!.endTime!;
    return Row(
      children: [
        Expanded(child: ElevatedButton(
          onPressed: () async {
            DateTime? pickedTime = await _updateDate(timeToView);
            if (pickedTime != null) {
              Time newTime = Time.mergeDateTime(timeToView, pickedTime);
              _setNewTime(isStartTime, newTime);
            }
          }, 
          child: Text(timeToView.date.toLabel()),
        )),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              TimeOfDay? pickedTime = await _updateTime(timeToView);
              if (pickedTime != null) {
                Time newTime = Time.mergeTimeOfDay(timeToView, pickedTime);
                _setNewTime(isStartTime, newTime);
              }
            },
            child: Text(timeToView.time.toLabel()),
          ),
        ),
      ],
    );
  } 

  void _setNewTime(bool isStartTime, Time newTime) {
    bool block = 
      (isStartTime && 
        (
          (
            widget.previousEvent != null && 
            Time.isTimeBefore(newTime, widget.previousEvent!.endTime, strict: true)
          ) ||
          (
            Time.isTimeBefore(widget.event!.endTime, newTime, strict: false)
          ) || 
          (
            Time.isTimeBefore(Time.now(), newTime)) && 
            !Time.sameDayAs(Time.now(), newTime)
        )
      ) ||
      (!isStartTime &&
        (
          (
            Time.isTimeBefore(newTime, widget.event!.startTime, strict: false)
          ) ||
          (
            widget.nextEvent != null && 
            Time.isTimeBefore(widget.nextEvent!.startTime, newTime, strict: true)
          )
        )
      )
    ;
    if(block) {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error: Överlappande tider"),
          content: const Text("Tiden du försöker välja är inte tillåten"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text("Stäng")
            ),
          ],
        );
      });
    } else {
      widget.data.removeEvent(widget.event!);
      isStartTime ? widget.event!.startTime = newTime : widget.event!.endTime = newTime;
      widget.data.addEvent(widget.event!);
      widget.updateData();
    }
  }

  Future<DateTime?> _updateDate(Time dateToUpdate) {
    return showDatePicker(
      context: context, 
      initialDate: DateTime(
        dateToUpdate.date.year,
        dateToUpdate.date.month,
        dateToUpdate.date.day,
      ),
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100),
    );
  }

  Future<TimeOfDay?> _updateTime(Time timeToUpdate) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: timeToUpdate.time.hour,
        minute: timeToUpdate.time.minute,
      ),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
  }

  Future<bool> _checkout(Event event) async {
    bool? checkoutAnyway = false;
    bool blocked = false;
    if(Time.isTimeBefore(Time.now(), event.startTime, strict: false)) {
      blocked = true;
      checkoutAnyway = await showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error: Överlappande tider"),
            content: Text("Om du väljer att fortsätta, så kommer ${event == widget.event ? "nuvarande" : "föregående"} händelse få samma sluttid som starttid"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                }, 
                child: const Text("Bekräfta")
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                }, 
                child: const Text("Avbryt")
              ),
            ],
          );
        }
      );
    } else {
      checkoutAnyway = true;
    }
    if(checkoutAnyway?? false) {
      
      widget.data.removeEvent(event);
      if(blocked) {
        event.endTime = event.startTime.deepCopy();
        event.endTime!.incrementMinute();
      } else {
        event.endTime = Time.nowOtherDate(widget.data.currentDate);
      }
      widget.data.addEvent(event);
      widget.updateData();
    }
    return checkoutAnyway?? false;
  }

  Future<bool> _addNewEvent() async {
    bool? addAnyway = false;
    bool moveOn = true;

    if(widget.previousEvent != null && widget.previousEvent!.endTime == null) {
      moveOn = await _checkout(widget.previousEvent!);
    }
    if(moveOn) {
      
      bool blocked = false;
      if(
        widget.previousEvent != null && 
        widget.previousEvent!.endTime != null && 
        Time.isTimeBefore(Time.nowOtherDate(widget.data.currentDate), widget.previousEvent!.endTime!) 
      ) {
        blocked = true;
        addAnyway = await showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error: Överlappande händelser"),
              content: const Text("Om du väljer att fortsätta kommer den nya händelsen att starta när den förra avslutades"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  }, 
                  child: const Text("Bekräfta")
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  }, 
                  child: const Text("Avbryt")
                ),
              ],
            );
          }
        );
      } else {
        addAnyway = true;
      }
      if(addAnyway?? false) {
        String? result = await _showEventSelectionDialog(context); 
        if (result != null) {
          Time startTime;
          Time? endTime;
          if(Time.sameDayAs(Time.now(), Time.fromEventDate(widget.data.currentDate))) {
            startTime = !blocked ? Time.now() : widget.previousEvent!.endTime!;
            endTime = null;
          } else {

            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: true,
                  ),
                  child: child!,
                );
              },
            );


            startTime = pickedTime != null ? Time.mergeTimeOfDay(Time.fromEventDate(widget.data.currentDate), pickedTime) 
            : (!blocked ? Time.nowOtherDate(widget.data.currentDate) : widget.previousEvent!.endTime!);
            endTime = startTime.deepCopy();
            endTime.incrementMinute();
          }

          Event newEvent = Event(
            member: widget.data.name.toFullString(),
            startTime: startTime,
            eventType: result,
            endTime: endTime,
          );
          widget.data.addEvent(newEvent);
          widget.updateData();
        }
      }
    }
    return addAnyway ?? false;
  }

  Future<String?> _showEventSelectionDialog(BuildContext context) async {

    TextEditingController customOptionController = TextEditingController();
    Map<String, Set<Event>> eventsByType = getSplitByType(widget.data.allEvents);
    List<String> options = widget.data.types.toList();
    options.sort((a, b) {
      Set<Event> eventsA = eventsByType[a] ?? {};
      Set<Event> eventsB = eventsByType[b] ?? {};
      bool checkedInA = isCheckedIn(eventsA);
      bool checkedInB = isCheckedIn(eventsB);
      if(checkedInA && !checkedInB) {
        return -1;
      } else if(checkedInB && !checkedInA) {
        return 1;
      }
      return a.compareTo(b);
    });

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Välj aktivitet'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  //height: 500.0,  // Adjust the height as needed
                  width: double.maxFinite, // Ensure the list view takes the available width
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        color: isCheckedIn(eventsByType[options[index]] ?? {}) ? Style.blue : null,
                        child: ListTile(
                          title: Text(options[index]),
                          onTap: () {
                            Navigator.pop(context, options[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        controller: customOptionController,
                        decoration: const InputDecoration(
                          hintText: 'Eller lägg till ny Aktivitet',
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      String customOption = customOptionController.text;
                      bool? confirmation = customOption.isEmpty ? false : await showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Bekräfta val"),
                          content: const Text("Du skapar nu en ny aktivitet som kommer läggas permanent i listan för existerande aktivitet.\nÄr du säker på att aktiviteten inte redan ligger i listan?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              }, 
                              child: const Text("Bekräfta")
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              }, 
                              child: const Text("Avbryt")
                            )
                          ],
                        );
                      });
                      if(confirmation == true) {
                        widget.data.addType(customOption);
                        widget.updateData();
                        Navigator.pop(context, customOption);
                      }
                    },
                    child: const Text('Lägg till'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    customOptionController.clear();

    return result;
  }

}