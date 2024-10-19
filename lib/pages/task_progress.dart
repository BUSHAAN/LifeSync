import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProgress extends StatefulWidget {
  final String taskName;
  final List<DocumentSnapshot> dailyItems;

  const TaskProgress({
    Key? key,
    required this.taskName,
    required this.dailyItems,
  }) : super(key: key);

  @override
  _TaskProgressState createState() => _TaskProgressState();
}

class _TaskProgressState extends State<TaskProgress> {
  late List<Map<String, dynamic>> modifiedDailyItems;
  int completedSubtasks = 0;

  @override
  void initState() {
    super.initState();
    _initializeDailyItems();
  }



  // Method to initialize dailyItems and count completed subtasks
  void _initializeDailyItems() {
    // Convert the dailyItems to a modifiable list of maps
    modifiedDailyItems = widget.dailyItems.map((item) {
      return {
        'docId': item.id,
        'isCompleted': item['isCompleted'] ?? false,
        'itemName': item['itemName'],
        'startDateTime': item['startDateTime'].toDate(),
        'endDateTime': item['endDateTime'].toDate(),
        'reference': item.reference,
      };
    }).toList();

    _calculateCompletedSubtasks();
  }

  // Method to calculate how many subtasks have been completed
  void _calculateCompletedSubtasks() {
    setState(() {
      completedSubtasks = modifiedDailyItems
          .where((item) => item['isCompleted'] == true)
          .length;
    });
  }

  // Method to update Firestore when 'Save Changes' is clicked
  Future<void> _saveChanges() async {
    for (var item in modifiedDailyItems) {
      await item['reference'].update({
        'isCompleted': item['isCompleted'],
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Progress saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalSubtasks = modifiedDailyItems.length;
    double progress =
        totalSubtasks > 0 ? (completedSubtasks / totalSubtasks) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Task Progress: ${widget.taskName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.taskName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 10),
            Text("${(progress * 100).toStringAsFixed(0)}% Completed"),

            SizedBox(height: 20),

            // Subtasks List
            Expanded(
              child: ListView.builder(
                itemCount: modifiedDailyItems.length,
                itemBuilder: (context, index) {
                  var item = modifiedDailyItems[index];
                  bool isCompleted = item['isCompleted'];

                  return ListTile(
                    title: Text(
                      "${item['itemName']}",
                      style: TextStyle(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                        "${item['startDateTime'].toString().substring(0, 16)} - ${item['endDateTime'].toString().substring(0, 16)}"),
                    trailing: Checkbox(
                      value: isCompleted,
                      onChanged: (bool? value) {
                        DateTime now = DateTime.now();
                        DateTime taskEndTime = item['endDateTime'];

                        if (taskEndTime.isAfter(now)) {
                          setState(() {
                            modifiedDailyItems[index]['isCompleted'] = value!;
                            _calculateCompletedSubtasks(); // Update progress in real time
                          });
                        } else if (!isCompleted) {
                          // If the task is expired and not yet completed, allow checking it
                          setState(() {
                            modifiedDailyItems[index]['isCompleted'] = value!;
                            _calculateCompletedSubtasks(); // Update progress in real time
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveChanges();
                  Navigator.pop(context);
                },
                child: Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
