import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDailyItemsPage extends StatefulWidget {
  @override
  _AddDailyItemsPageState createState() => _AddDailyItemsPageState();
}

class _AddDailyItemsPageState extends State<AddDailyItemsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _refIdController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _deleteRefIdController = TextEditingController();

    Future<void> addDailyItemsForMultipleDays({
    required String taskName,
    required String userId,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required double duration,
    required String refId,
    required int days, // Number of days to add the task
  }) async {
    // Firestore reference to the "DailyItems" collection
    final CollectionReference<Map<String, dynamic>> dailyItems =
        FirebaseFirestore.instance.collection("DailyItems");

    // Iterate for the given number of days and add a task for each day
    for (int i = 0; i < days; i++) {
      if (endDateTime.isBefore(startDateTime)) {
        // Add one day to endDateTime to account for the overnight event
        endDateTime = endDateTime.add(Duration(days: 1));
      }
      DateTime currentStartDateTime = startDateTime.add(Duration(days: i));
      DateTime currentEndDateTime = endDateTime.add(Duration(days: i));
      
      await dailyItems.add({
        "userId": userId,
        "itemName": taskName,
        "isEvent": true,
        "startDateTime": currentStartDateTime,
        "endDateTime": currentEndDateTime,
        "duration": duration,
        "refId": refId,
        "isCompleted": true,
      });
    }
  }
  // DateTime format (24-hour)
  final DateFormat _dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Convert TimeOfDay to 24-hour format
      final now = DateTime.now();
      final DateTime fullTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      controller.text = DateFormat('HH:mm:ss').format(fullTime); // e.g., "19:16:00"
    }
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      String taskName = _taskNameController.text;
      String userId = _userIdController.text;
      String refId = _refIdController.text;

      // Combine the date and time into a single DateTime object
      DateTime startDateTime = DateTime.parse(
          "${_startDateController.text} ${_startTimeController.text}");
      DateTime endDateTime = DateTime.parse(
          "${_startDateController.text} ${_endTimeController.text}");

      double duration = double.parse(_durationController.text);
      int days = int.parse(_daysController.text);

      await addDailyItemsForMultipleDays(
        taskName: taskName,
        userId: userId,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        duration: duration,
        refId: refId,
        days: days,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Task added successfully')));
    }
  }

  Future<void> _deleteDailyItems(String refId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("DailyItems")
        .where('refId', isEqualTo: refId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All DailyItems with refId $refId deleted')));
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete DailyItems'),
          content: TextField(
            controller: _deleteRefIdController,
            decoration: InputDecoration(labelText: 'Enter Reference ID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String refId = _deleteRefIdController.text;
                await _deleteDailyItems(refId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Daily Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(labelText: 'Task Name'),
                validator: (value) => value!.isEmpty ? 'Enter task name' : null,
              ),
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'User ID'),
                validator: (value) => value!.isEmpty ? 'Enter user ID' : null,
              ),
              TextFormField(
                controller: _refIdController,
                decoration: InputDecoration(labelText: 'Reference ID'),
                validator: (value) => value!.isEmpty ? 'Enter reference ID' : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: 'Start Date'),
                readOnly: true,
                onTap: () => _selectDate(context, _startDateController),
                validator: (value) => value!.isEmpty ? 'Enter start date' : null,
              ),
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(labelText: 'Start Time (24h)'),
                readOnly: true,
                onTap: () => _selectTime(context, _startTimeController),
                validator: (value) => value!.isEmpty ? 'Enter start time' : null,
              ),
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(labelText: 'End Time (24h)'),
                readOnly: true,
                onTap: () => _selectTime(context, _endTimeController),
                validator: (value) => value!.isEmpty ? 'Enter end time' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (hours)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter duration' : null,
              ),
              TextFormField(
                controller: _daysController,
                decoration: InputDecoration(labelText: 'Number of Days'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter number of days' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  _addTask();
                  Navigator.pop(context);
                },
                child: Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
