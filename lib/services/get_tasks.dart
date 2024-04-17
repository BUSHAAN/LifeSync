import 'package:cloud_firestore/cloud_firestore.dart';

class GetTasks {
  final String documentId;

  GetTasks({required this.documentId});

  Future<Map<String, dynamic>> getTaskData() async {
    final docRef = FirebaseFirestore.instance.collection('Tasks').doc(documentId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      
      return snapshot.data() as Map<String, dynamic>;
    } else {
      print('No task found for document ID: $documentId');
      return {}; // Return an empty map if document doesn't exist
    }
  }
}