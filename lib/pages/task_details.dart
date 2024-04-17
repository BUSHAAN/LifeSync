import 'package:flutter/material.dart';

class TaskDetails extends StatefulWidget {
  final Map<String, dynamic> taskData;

  const TaskDetails({super.key, required this.taskData});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  String title = '';
  String priority = "";

  @override
  void initState() {
    super.initState();
    title = widget.taskData['taskName'];
    priority = widget.taskData['priority'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: title),
              onChanged: (value) => setState(() => title = value),
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: TextEditingController(text: priority),
              onChanged: (value) => setState(() => title = value),
              decoration: InputDecoration(labelText: 'Priority'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  // Update task details in Firestore using widget.taskData['id']
                  // ...
                },
                child: Text('Save Changes')),
          ],
        ),
      ),
    );
  }
}
