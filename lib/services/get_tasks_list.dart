import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetTaskList extends StatelessWidget {
  final String documentId;

  GetTaskList({required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection("Tasks");

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(documentId).get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
                return Text(data['taskName']);
          }
          else{
            return const Text('loading...');
          }
        }));
  }
}
