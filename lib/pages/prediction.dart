// ignore_for_file: prefer_const_constructors

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/services/task_prediction_services.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  final MLServices mlServices = MLServices();
  String? predictionText = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mlServices.checkForFreeSlotAndPredict().then((prediction) {
      if (prediction != null) {
        setState(() {
          predictionText = prediction;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            predictionText == ""
                ? const CircularProgressIndicator()
                : Card(
                        elevation: 4,
                        color: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: 
                          Text(
                            (predictionText == "You have a task scheduled right now")?
                            'Your schedule is occupied at the current time':
                            'Prediction: $predictionText',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mlServices.checkForFreeSlotAndPredict();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
