// ignore_for_file: avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/task_details.dart';
import 'package:flutter_todo_app/services/firestore.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  final user = FirebaseAuth.instance.currentUser;
  final FireStoreService fireStoreService = FireStoreService();

  void goHome() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
                onPressed: goHome,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ))
          ],
          centerTitle: true,
          title: const Text(
            "LifeSync",
            style: (TextStyle(
              color: Colors.white,
            )),
          ),
          backgroundColor: Colors.blue.shade600,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.getTasksStream(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List tasksList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: tasksList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = tasksList[index];
                  String docId = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  String taskTitle = data['taskName'];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Card(
                        child: ListTile(
                      onTap: () async {
                        final taskData = await fireStoreService.getTaskData(docId);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetails(taskData: taskData,documentId: docId),
                            ),
                          );
                      },
                      title: Text(taskTitle),
                    )),
                  );
                },
              );
            } else {
              return const Text("loading....");
            }
          },
        ));
  }
}
