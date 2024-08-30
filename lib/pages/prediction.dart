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
        title: const Text('Prediction'),
      ),
      body: Center(
        child: Text(predictionText != null
            ? 'Prediction: $predictionText'
            : 'Prediction Page'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            
          },
          child: const Icon(Icons.add)),
    );
  }
}
