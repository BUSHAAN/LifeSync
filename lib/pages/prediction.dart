import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/quick_add_task.dart';
import 'package:flutter_todo_app/services/task_prediction_services.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final MLServices mlServices = MLServices();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic> predictionText = {};
  bool isScheduleFree = true;

  @override
  void initState() {
    super.initState();
    mlServices.isCurrentTaskOrFreeSlot(userId).then((isFree) {
      setState(() {
        isScheduleFree = isFree;
      });
    });
    mlServices.checkForFreeSlotAndPredict().then((prediction) {
      setState(() {
        predictionText = prediction;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: const Text('Prediction Page', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show message only when predictionText is not empty
            if (predictionText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Would you like to try one of these tasks?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            // Show loading indicator or tasks
            predictionText.isEmpty
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: predictionText['predictions']?.length ?? 0,
                      itemBuilder: (context, index) {
                        final predictionItem = predictionText['predictions'][index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              predictionItem['prediction'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Confidence: ${(predictionItem['confidence'] * 100).toStringAsFixed(2)}%',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add, color: Colors.blue),
                              onPressed: () {
                                // Handle adding the task here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuickAddTasksPage(
                                      taskName: predictionItem['prediction'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mlServices.checkForFreeSlotAndPredict().then((prediction) {
            setState(() {
              predictionText = prediction;
            });
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
