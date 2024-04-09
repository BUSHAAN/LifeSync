import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  final Map<String, dynamic> taskDataDetails;
  const NextPage({super.key, required this.taskDataDetails});

  @override
  Widget build(BuildContext context) {
    String title = taskDataDetails['taskName'] ?? "";
    String duration = taskDataDetails['duration'].toString() ?? "";
    DateTime? deadline = taskDataDetails['deadline'];
    String? schedule = taskDataDetails['schedule'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
            children: [
              const Text(
                'Title:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(title),
              const SizedBox(height: 10.0), // Add spacing between sections
              const Text(
                'Duration:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text('$duration hours'),
              const SizedBox(height: 10.0),
              const Text(
                'Deadline:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(deadline?.toString() ??
                  "No Deadline Set"), // Format deadline if available
              const SizedBox(height: 10.0),
              const Text(
                'Schedule:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(schedule ?? "No Schedule Set"),
            ],
          ),
        ),
      ),
    );
  }
}
