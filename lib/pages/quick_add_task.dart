// ignore_for_file: prefer_const_constructors, unused_field, duplicate_ignore
import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/task.dart';
import 'package:flutter_todo_app/services/firestore.dart';

class QuickAddTasksPage extends StatefulWidget {
  final String taskName; // Accept a taskName as a parameter

  const QuickAddTasksPage({super.key, required this.taskName});

  @override
  State<QuickAddTasksPage> createState() => _QuickAddTasksPageState();
}

class _QuickAddTasksPageState extends State<QuickAddTasksPage> {
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  final FireStoreService fireStoreService = FireStoreService();
  late final TextEditingController _taskNameController;
  late final TextEditingController _durationController;
  bool _allowSplitting = false;
  final _maxChunkTimeController = TextEditingController();
  String _deadlineType = "";
  DateTime? _deadline;
  DateTime? _startDate;
  String _schedule = "";

  final List<String> _priorities = ["high", "medium", "low"];
  final List<String> _deadlineTypes = [
    "hard deadline",
    "soft deadline",
    "no deadline"
  ];
  final List<String> _schedules = [
    "Morning",
    "Afternoon",
    "Evening",
    "Late Night",
  ];

  @override
  void dispose() {
    _taskNameController.dispose();
    _durationController.dispose();
    _maxChunkTimeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with default values
    _taskNameController = TextEditingController(text: widget.taskName);
    _durationController = TextEditingController(text: "2"); // Default duration
  }

  @override
  Widget build(BuildContext quickContext) {
    Task newTask = Task(
      userId: _userId,
      taskName: _taskNameController.text.trim(),
      duration: double.tryParse(_durationController.text.trim()),
      allowSplitting: false,
      maxChunkTime: null,
      deadlineType: "no deadline",
      deadline: null,
      startDate: DateTime.now(),
      schedule: "morning",
      isDone: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Task"),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            child: Column(
              children: [
                // Task name (read-only field for quick add)
                TextFormField(
                  controller: _taskNameController,
                  decoration: InputDecoration(labelText: "Task Name"),
                  readOnly: true, // Make it read-only
                ),
                // Duration
                Row(
                  children: [
                    Text("Duration (hours): "),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "0.0"),
                        validator: (value) => double.tryParse(value!) == null
                            ? "Invalid duration"
                            : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    bool isAdded = await fireStoreService.quickAddTaskDetails(
                      newTask,
                    );
                    if (isAdded) {
                      Navigator.pop(quickContext);
                      Navigator.pop(context);

                    }
                  },
                  child: Text("Quick Add"),
                ),
              ],
            ),
          )),
    );
  }
}
