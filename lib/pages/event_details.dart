// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/services/firestore.dart';

class EventDetails extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String documentId;
  const EventDetails(
      {super.key, required this.eventData, required this.documentId});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  FireStoreService fireStoreService = FireStoreService();
  DateTime? _startTime;
  DateTime? _endTime;
  List<dynamic> _selectedWeekdays = [];
  final List<String> _frequencies = ["Daily", "Weekly", "One-Time"];

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context, initialTime: widget.eventData['startTime']);
    if (pickedTime != null &&
        (pickedTime.hour != _startTime?.hour ||
            pickedTime.minute != _startTime?.minute)) {
      setState(() {
        // Update only the time part of _deadline
        _startTime = DateTime(
            _startTime?.year ?? DateTime.now().year,
            _startTime?.month ?? DateTime.now().month,
            _startTime?.day ?? DateTime.now().day,
            pickedTime.hour,
            pickedTime.minute);
        widget.eventData['startTime'] = _startTime;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context, initialTime: widget.eventData['endTime']);
    if (pickedTime != null &&
        (pickedTime.hour != _endTime?.hour ||
            pickedTime.minute != _endTime?.minute)) {
      setState(() {
        // Update only the time part of _deadline
        _endTime = DateTime(
            _endTime?.year ?? DateTime.now().year,
            _endTime?.month ?? DateTime.now().month,
            _endTime?.day ?? DateTime.now().day,
            pickedTime.hour,
            pickedTime.minute);
            widget.eventData['endTime'] = _endTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedWeekdays = widget.eventData['selectedWeekdays'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Event'),
      ),
      body: (SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.eventData['eventName'],
                  decoration: InputDecoration(
                    labelText: "Event Name",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a event name" : null,
                  onChanged: (newValue) =>
                      setState(() => widget.eventData["taskName"] = newValue),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Set Start time: ",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () => _selectStartTime(context),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_outlined),
                          SizedBox(width: 5.0),
                          Text(widget.eventData["startTime"]
                                  .toDate()
                                  ?.toString()
                                  .substring(10, 16) ??
                              "--:--"),
                        ],
                      ), // Display only time part
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Set End time: ",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () => _selectEndTime(context),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_outlined),
                          SizedBox(width: 5.0),
                          Text(widget.eventData["endTime"]
                                  .toDate()
                                  ?.toString()
                                  .substring(10, 16) ??
                              "--:--"),
                        ],
                      ), // Display only time part
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Frequency:  "),
                    value: widget.eventData['frequency'],
                    items: _frequencies
                        .map((schedule) => DropdownMenuItem<String>(
                              value: schedule,
                              child: Text(schedule),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => widget.eventData['frequency'] = value!)),
                SizedBox(
                  height: 20,
                ),
                if (widget.eventData['frequency'] == "Weekly")
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select weekdays to repeat:",
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _selectedWeekdays
                                    .contains(DateTime.monday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays.add(DateTime.monday);
                                  } else {
                                    _selectedWeekdays.remove(DateTime.monday);
                                  }
                                }),
                              ),
                              Text('Monday'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _selectedWeekdays
                                    .contains(DateTime.tuesday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays.add(DateTime.tuesday);
                                  } else {
                                    _selectedWeekdays.remove(DateTime.tuesday);
                                  }
                                }),
                              ),
                              Text('Tuesday'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _selectedWeekdays
                                    .contains(DateTime.wednesday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays.add(DateTime.wednesday);
                                  } else {
                                    _selectedWeekdays
                                        .remove(DateTime.wednesday);
                                  }
                                }),
                              ),
                              Text('Wednesday'),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _selectedWeekdays
                                    .contains(DateTime.thursday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays.add(DateTime.thursday);
                                  } else {
                                    _selectedWeekdays.remove(DateTime.thursday);
                                  }
                                }),
                              ),
                              Text('Thursday'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _selectedWeekdays
                                    .contains(DateTime.friday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays.add(DateTime.friday);
                                  } else {
                                    _selectedWeekdays.remove(DateTime.friday);
                                  }
                                }),
                              ),
                              Text('Friday'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _selectedWeekdays
                                    .contains(DateTime.saturday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays.add(DateTime.saturday);
                                  } else {
                                    _selectedWeekdays.remove(DateTime.saturday);
                                  }
                                }),
                              ),
                              Text('Saturday'),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _selectedWeekdays
                                .contains(DateTime.sunday), // Monday
                            onChanged: (newValue) => setState(() {
                              if (newValue!) {
                                _selectedWeekdays.add(DateTime.sunday);
                              } else {
                                _selectedWeekdays.remove(DateTime.sunday);
                              }
                            }),
                          ),
                          Text('Sunday'),
                        ],
                      ),
                    ],
                  ),
                ElevatedButton(
                    onPressed: () {
                      //fireStoreService.update(newEvent);
                      Navigator.pop(context);
                    },
                    child: Text('Add Event'))
              ],
            ),
          ),
        ),
      )),
    );
  }
}
