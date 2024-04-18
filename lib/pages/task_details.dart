// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/Task.dart';
import 'package:flutter_todo_app/services/firestore.dart';

class TaskDetails extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final String documentId;

  const TaskDetails({super.key, required this.taskData, required this.documentId});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final FireStoreService fireStoreService = FireStoreService();
  DateTime? _deadline;
  DateTime? _startDate;
  final List<String> _priorities = ["high", "medium", "low"];
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Task newTask = Task(
    //   // Create a new Task object
    //   userId: widget.taskData["userId"],
    //   taskName: widget.taskData["taskName"],
    //   duration: widget.taskData["duration"],
    //   allowSplitting: widget.taskData["allowSplitting"],
    //   maxChunkTime: widget.taskData["maxChunkTime"],
    //   priority: widget.taskData["priority"], // Set default priority
    //   deadlineType: widget.taskData["deadlineType"],
    //   deadline: widget.taskData["deadline"].toDate(),
    //   startDate: widget.taskData["startDate"].toDate(),
    //   schedule: widget.taskData["schedule"], // Set default schedule
    //   isDone: widget.taskData["allowSplitting"],
    // );
    // ignore: prefer_const_constructors
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            //Task name
            TextFormField(
              initialValue: widget.taskData["taskName"],
              decoration: InputDecoration(labelText: "Task Name"),
              validator: (value) =>
                  value!.isEmpty ? "Please enter a task name" : null,
              onChanged: (newValue) =>
                  setState(() => widget.taskData["taskName"] = newValue),
            ),
            //Duration
            Row(
              children: [
                Text("Duration (hours): "),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                        text: widget.taskData["duration"].toString()),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() =>
                        widget.taskData["duration"] = double.tryParse(value)),
                    decoration: InputDecoration(hintText: "0.0"),
                    validator: (value) => double.tryParse(value!) == null
                        ? "Invalid duration"
                        : null,
                  ),
                ),
              ],
            ),
            // Splitting Checkbox
            Row(
              children: [
                Checkbox(
                  value: widget.taskData["allowSplitting"],
                  onChanged: (value) => setState(
                      () => widget.taskData["allowSplitting"] = value!),
                ),
                Text("Allow Splitting"),
              ],
            ),
            // Max Chunk Time (if splitting allowed)
            Visibility(
              visible: widget.taskData["allowSplitting"],
              child: Row(
                children: [
                  Text("Max Chunk Time (hours): "),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(
                          text: widget.taskData["maxChunkTime"].toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "0.0"),
                      validator: (value) => double.tryParse(value!) == null
                          ? "Invalid duration"
                          : null,
                      enabled: widget.taskData["allowSplitting"],
                    ),
                  ),
                ],
              ),
            ),
            // Priority Dropdown
            DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Priority"),
                value: widget.taskData["priority"],
                items: _priorities
                    .map((priority) => DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => widget.taskData["priority"] = value!)),
            // Deadline Type Dropdown
            DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Deadline Type"),
                value: widget.taskData["deadlineType"],
                items: _deadlineTypes
                    .map((deadlineType) => DropdownMenuItem<String>(
                          value: deadlineType,
                          child: Text(deadlineType),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => widget.taskData["deadlineType"] = value!)),
            // Deadline Date Picker
            Visibility(
              visible: (widget.taskData["deadlineType"] != "no deadline"),
              child: Row(
                children: [
                  Text("Deadline: "),
                  TextButton(
                    onPressed: () {
                      _selectDeadlineDate(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined), // Calendar icon
                        SizedBox(width: 5.0),
                        Text(widget.taskData["deadline"].toDate()
                                ?.toString()
                                .substring(0, 10) ??
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
                        Text(widget.taskData["deadline"].toDate()
                                ?.toString()
                                .substring(11, 16) ??
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
                  onPressed: () {
                    _selectStartDate(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined),
                      SizedBox(width: 5.0),
                      Text(widget.taskData["startDate"].toDate()?.toString() ??
                          "Set date"),
                    ],
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Schedule "),
                value: widget.taskData["schedule"],
                items: _schedules
                    .map((schedule) => DropdownMenuItem<String>(
                          value: schedule,
                          child: Text(schedule),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => widget.taskData["schedule"] = value!)),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                print(widget.taskData['deadline']);
                await fireStoreService.updateTask(
                    widget.documentId, widget.taskData);
                Navigator.pop(context);
              },
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
