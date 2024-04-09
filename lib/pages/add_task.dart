// ignore_for_file: prefer_const_constructors
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/next_page.dart';

class AddTasksPage extends StatefulWidget {
  const AddTasksPage({super.key});

  @override
  State<AddTasksPage> createState() => _AddTasksPageState();
}

class _AddTasksPageState extends State<AddTasksPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _taskName = "";
  double _duration = 0.0; // Assuming hours
  bool _allowSplitting = false;
  double _maxChunkTime = 0.0; // Assuming hours
  String _priority = ""; // Default priority
  String _deadlineType = ""; // Default deadline type
  DateTime? _deadline;
  DateTime? _startDate;
  String _schedule = "";

  final List<String> _priorities = ["high", "med", "low"];
  final List<String> _deadlineTypes = [
    "hard deadline",
    "soft deadline",
    "no deadline"
  ];
  final List<String> _schedules = [
    "mornings",
    "daytime",
    "after hours",
    "late night",
  ];

  Map<String, dynamic> prepareData() {
    return {
      "taskName": _taskName,
      "duration": _duration,
      "allowSplitting": _allowSplitting,
      "maxChunkTime": _allowSplitting == true ? _maxChunkTime : null,
      "priority": _priority,
      "deadlineType": _deadlineType,
      "deadline": _deadlineType == "no deadline" ? null : _deadline,
      "startDate": _startDate,
      "schedule": _schedule,
    };
  }

  // Function to show date picker for Deadline

  Future<void> _selectDeadlineDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline?.year != null
          ? DateTime(
              _deadline?.year ?? 0, _deadline?.month ?? 0, _deadline?.day ?? 0)
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null &&
        (pickedDate.year != _deadline?.year ||
            pickedDate.month != _deadline?.month ||
            pickedDate.day != _deadline?.day)) {
      setState(() {
        // Update only the date part of _deadline
        _deadline = DateTime(
            _deadline?.year ?? pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _deadline?.hour ?? 0,
            _deadline?.minute ?? 0);
      });
    }
  }

  // Function to show date picker for Start Date
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

  Future<void> _selectDeadlineTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _deadline != null
          ? TimeOfDay.fromDateTime(_deadline!)
          : TimeOfDay.now(),
    );
    if (pickedTime != null &&
        (pickedTime.hour != _deadline?.hour ||
            pickedTime.minute != _deadline?.minute)) {
      setState(() {
        // Update only the time part of _deadline
        _deadline = DateTime(
            _deadline?.year ?? DateTime.now().year,
            _deadline?.month ?? DateTime.now().month,
            _deadline?.day ?? DateTime.now().day,
            pickedTime.hour,
            pickedTime.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //Task name
                TextFormField(
                    decoration: InputDecoration(labelText: "Task Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter a task name" : null,
                    onSaved: (value) => setState(() => _taskName = value!)),
                //Duration
                Row(
                  children: [
                    Text("Duration (hours): "),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "0.0"),
                        validator: (value) => double.tryParse(value!) == null
                            ? "Invalid duration"
                            : null,
                        onSaved: (value) =>
                            setState(() => _duration = double.parse(value!)),
                      ),
                    ),
                  ],
                ),
                // Splitting Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _allowSplitting,
                      onChanged: (value) =>
                          setState(() => _allowSplitting = value!),
                    ),
                    Text("Allow Splitting"),
                  ],
                ),
                // Max Chunk Time (if splitting allowed)
                Visibility(
                  visible: _allowSplitting,
                  child: Row(
                    children: [
                      Text("Max Chunk Time (hours): "),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: "0.0"),
                          validator: (value) => double.tryParse(value!) == null
                              ? "Invalid duration"
                              : null,
                          onSaved: (value) => setState(
                              () => _maxChunkTime = double.parse(value!)),
                          enabled: _allowSplitting,
                        ),
                      ),
                    ],
                  ),
                ),
                // Priority Dropdown
                DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Priority"),
                    items: _priorities
                        .map((priority) => DropdownMenuItem<String>(
                              value: priority,
                              child: Text(priority),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _priority = value!)),
                // Deadline Type Dropdown
                DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Deadline Type"),
                    items: _deadlineTypes
                        .map((deadlineType) => DropdownMenuItem<String>(
                              value: deadlineType,
                              child: Text(deadlineType),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _deadlineType = value!)),
                // Deadline Date Picker
                Visibility(
                  visible: (_deadlineType != "no deadline"),
                  child: Row(
                    children: [
                      Text("Deadline: "),
                      TextButton(
                        onPressed: () => _selectDeadlineDate(context),
                        child: Row(
                          children: [
                            Icon(
                                Icons.calendar_today_outlined), // Calendar icon
                            SizedBox(width: 5.0),
                            Text(_deadline?.toString().substring(0, 10) ??
                                "Set date"),
                          ],
                        ), // Display only date part
                      ),
                      SizedBox(width: 10.0),
                      TextButton(
                        onPressed: () => _selectDeadlineTime(context),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_outlined),
                            SizedBox(width: 5.0),
                            Text(_deadline?.toString().substring(11, 16) ??
                                "Set time"),
                          ],
                        ), // Display only time part
                      ),
                    ],
                  ),
                ),
                // Start Date Date Picker
                Row(
                  children: [
                    Text("Start Date: "),
                    TextButton(
                      onPressed: () => _selectStartDate(context),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined),
                          SizedBox(width: 5.0),
                          Text(_startDate?.toString() ?? "Set date"),
                        ],
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Schedule "),
                    items: _schedules
                        .map((schedule) => DropdownMenuItem<String>(
                              value: schedule,
                              child: Text(schedule),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _schedule = value!)),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Prepare data and navigate to next page using Navigator.push
                      Map<String, dynamic> taskData = prepareData();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NextPage(taskDataDetails: taskData)),
                      ).then((_) => _formKey.currentState?.reset());
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          )),
    );
  }
}
