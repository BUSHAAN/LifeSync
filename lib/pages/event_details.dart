// ignore_for_file: prefer_const_constructors

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

  @override
  void initState() {
    _startTime = (widget.eventData['startTime'] as Timestamp).toDate();
    _endTime = (widget.eventData['endTime'] as Timestamp).toDate();
    _startDate = widget.eventData['frequency'] == 'One-Time' ? (widget.eventData['startDate'] as Timestamp).toDate() : DateTime.now();
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
      body: SingleChildScrollView(
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
                      value!.isEmpty ? "Please enter an event name" : null,
                  onChanged: (newValue) =>
                      setState(() => widget.eventData["eventName"] = newValue),
                ),
                SizedBox(height: 10),
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
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
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
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Frequency can\'t be changed'),
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      initialValue: widget.eventData['frequency'],
                      decoration: InputDecoration(
                        labelText: "Frequency",
                      ),
                      onChanged: (value) {
                        // No changes should be allowed, so we don't need to handle this
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Visibility(
                  visible: widget.eventData['frequency'] == "Weekly",
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Weekdays selection can't be changed")),
                      );
                    },
                    child: AbsorbPointer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select weekdays to repeat:",
                            style: TextStyle(fontSize: 16),
                          ),
                          Wrap(
                            spacing: 10.0,
                            runSpacing: 10.0,
                            children: [
                              for (var day in {
                                DateTime.monday: "Monday",
                                DateTime.tuesday: "Tuesday",
                                DateTime.wednesday: "Wednesday",
                                DateTime.thursday: "Thursday",
                                DateTime.friday: "Friday",
                                DateTime.saturday: "Saturday",
                                DateTime.sunday: "Sunday",
                              }.entries)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value:
                                          _selectedWeekdays?.contains(day.key),
                                      onChanged: (newValue) {},
                                    ),
                                    Text(day.value),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      widget.eventData['startTime'] = _startTime;
                      widget.eventData['endTime'] = _endTime;
                      widget.eventData['startDate'] =
                          widget.eventData['frequency'] == "One-Time"
                              ? _startDate
                              : null;
                      fireStoreService.updateEvent(
                          widget.documentId, widget.eventData);
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
