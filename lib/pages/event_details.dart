// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
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
  DateTime? _startDate;
  List<dynamic>? _selectedWeekdays = [];
  final List<String> _frequencies = ["Daily", "Weekly", "One-Time"];

  @override
  void initState() {
    _startTime = (widget.eventData['startTime'] as Timestamp).toDate();
    _endTime = (widget.eventData['endTime'] as Timestamp).toDate();

    _startDate = DateTime.now();
    print("This is the print statement:" + _startTime.toString());
    _selectedWeekdays = widget.eventData['selectedWeekdays'];
    super.initState();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime != null
          ? TimeOfDay.fromDateTime(_startTime!)
          : TimeOfDay.now(),
    );
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
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime != null
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay.now());
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
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedWeekdays = widget.eventData['selectedWeekdays'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
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
                          Text(_startTime?.toString().substring(10, 16) ??
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
                          Text(_endTime?.toString().substring(10, 16) ??
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
                Visibility(
                  visible: widget.eventData['frequency'] == "Weekly",
                  child: Column(
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
                                    ?.contains(DateTime.monday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays?.add(DateTime.monday);
                                  } else {
                                    _selectedWeekdays?.remove(DateTime.monday);
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
                                    ?.contains(DateTime.tuesday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays?.add(DateTime.tuesday);
                                  } else {
                                    _selectedWeekdays?.remove(DateTime.tuesday);
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
                                    ?.contains(DateTime.wednesday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays?.add(DateTime.wednesday);
                                  } else {
                                    _selectedWeekdays
                                        ?.remove(DateTime.wednesday);
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
                                    ?.contains(DateTime.thursday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays?.add(DateTime.thursday);
                                  } else {
                                    _selectedWeekdays
                                        ?.remove(DateTime.thursday);
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
                                    ?.contains(DateTime.friday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays?.add(DateTime.friday);
                                  } else {
                                    _selectedWeekdays?.remove(DateTime.friday);
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
                                    ?.contains(DateTime.saturday), // Monday
                                onChanged: (newValue) => setState(() {
                                  if (newValue!) {
                                    _selectedWeekdays?.add(DateTime.saturday);
                                  } else {
                                    _selectedWeekdays
                                        ?.remove(DateTime.saturday);
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
                                ?.contains(DateTime.sunday), // Monday
                            onChanged: (newValue) => setState(() {
                              if (newValue!) {
                                _selectedWeekdays?.add(DateTime.sunday);
                              } else {
                                _selectedWeekdays?.remove(DateTime.sunday);
                              }
                            }),
                          ),
                          Text('Sunday'),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.eventData['frequency'] == "One-Time",
                  child: Row(
                    children: [
                      Text(
                        "Select Start Date: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () => _selectStartDate(context),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 5.0),
                            Text(_startDate?.toString().substring(0, 10) ??
                                "Set date"),
                          ],
                        ), // Display only time part
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        widget.eventData['startTime'] = _startTime;
                        widget.eventData['endTime'] = _endTime;
                        widget.eventData['startDate'] =
                            widget.eventData['frequency'] == "One-Time"
                                ? _startDate
                                : null;
                        widget.eventData['selectedWeekdays'] =
                            widget.eventData['frequency'] == "Weekly"
                                ? _selectedWeekdays
                                : null;
                        fireStoreService.updateEvent(
                            widget.documentId, widget.eventData);
                        Navigator.pop(context);
                      });
                    },
                    child: Text('Save Changes'))
              ],
            ),
          ),
        ),
      )),
    );
  }
}
