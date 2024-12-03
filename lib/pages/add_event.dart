// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, prefer_if_null_operators

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/event.dart';
import 'package:flutter_todo_app/services/firestore.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  FireStoreService fireStoreService = FireStoreService();
  final _eventNameController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  String _frequency = "";
  List<int> _selectedWeekdays = [];
  DateTime? _startDate;

  final List<String> _frequencies = ["Daily", "Weekly", "One-Time"];

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
          : TimeOfDay.now(),
    );
    if (pickedTime != null &&
        (pickedTime.hour != _endTime?.hour ||
            pickedTime.minute != _endTime?.minute)) {
      setState(() {
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
    Event newEvent = Event(
      userId: _userId,
      eventName: _eventNameController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      frequency: _frequency,
      selectedWeekdays: _selectedWeekdays,
      startDate: _startDate,
    );
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
                  controller: _eventNameController,
                  decoration: InputDecoration(
                    labelText: "Event Name",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a event name" : null,
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
                    items: _frequencies
                        .map((schedule) => DropdownMenuItem<String>(
                              value: schedule,
                              child: Text(schedule),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _frequency = value!)),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: _frequency == "Weekly",
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
                ),
                Visibility(
                  visible: _frequency == "One-Time",
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
                            Text(_startDate?.toString().substring(0, 10) ?? ""),
                          ],
                        ), // Display only time part
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic>? result =
                        await fireStoreService.addEventDetails(newEvent);

                    if (result != null && result['hasConflict']) {
                      Map<String, dynamic> blockingEvent =
                          result['blockingEvent'].data()
                              as Map<String, dynamic>;

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Event Conflict"),
                            content: blockingEvent['frequency'] == 'One-Time'
                                ? Text(
                                    "The event '${blockingEvent['eventName']}' scheduled from ${blockingEvent['startTime'].toDate().hour}:${blockingEvent['startTime'].toDate().minute.toString().padLeft(2, '0')} to ${blockingEvent['endTime'].toDate().hour}:${blockingEvent['endTime'].toDate().minute.toString().padLeft(2, '0')} on ${blockingEvent['startDate'].toDate().day}-${blockingEvent['startDate'].toDate().month}-${blockingEvent['startDate'].toDate().year} conflicts with your new event.")
                                : blockingEvent['frequency'] == 'Weekly'
                                    ? Text(
                                        "The event '${blockingEvent['eventName']}' scheduled weekly on ${blockingEvent['selectedWeekdays'].map((weekday) {
                                        switch (weekday) {
                                          case DateTime.monday:
                                            return 'Monday';
                                          case DateTime.tuesday:
                                            return 'Tuesday';
                                          case DateTime.wednesday:
                                            return 'Wednesday';
                                          case DateTime.thursday:
                                            return 'Thursday';
                                          case DateTime.friday:
                                            return 'Friday';
                                          case DateTime.saturday:
                                            return 'Saturday';
                                          case DateTime.sunday:
                                            return 'Sunday';
                                          default:
                                            return '';
                                        }
                                      }).join(', ')} from ${blockingEvent['startTime'].toDate().hour}:${blockingEvent['startTime'].toDate().minute.toString().padLeft(2, '0')} to ${blockingEvent['endTime'].toDate().hour}:${blockingEvent['endTime'].toDate().minute.toString().padLeft(2, '0')} conflicts with your new event.")
                                    : Text(
                                        "The event '${blockingEvent['eventName']}' scheduled daily from ${blockingEvent['startTime'].toDate().hour}:${blockingEvent['startTime'].toDate().minute.toString().padLeft(2, '0')} to ${blockingEvent['endTime'].toDate().hour}:${blockingEvent['endTime'].toDate().minute.toString().padLeft(2, '0')} conflicts with your new event."),
                            actions: [
                              TextButton(
                                child: const Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else if (result != null && !result['hasConflict']) {
                      Map<String, dynamic> deadlineExTask =
                          result['deadlineExTask'];
                      showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text("Deadline Exceeded"),
                              content: Text(
                                  "Deadline of the task '${deadlineExTask['taskName']}' scheduled on ${deadlineExTask['startDate'].toDate().day}-${deadlineExTask['startDate'].toDate().month}-${deadlineExTask['startDate'].toDate().year} will be exceeded. Do you want to add the event anyway? (This will remove the deadline from the task)"),
                              actions: [
                                TextButton(
                                  child: const Text("Yes"),
                                  onPressed: () async {
                                    deadlineExTask['deadlineType'] =
                                        'no deadline';
                                    deadlineExTask['deadline'] = null;
                                    await fireStoreService.updateTask(
                                        deadlineExTask['documentId'],
                                        deadlineExTask);
                                    await fireStoreService.addEventDetails(
                                      newEvent,
                                    );
                                    Navigator.pop(dialogContext);
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text("No"),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                ),
                              ],
                            );
                          });
                    } else {
                      Navigator.pop(
                          context); // Close the dialog if the event is added successfully
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
