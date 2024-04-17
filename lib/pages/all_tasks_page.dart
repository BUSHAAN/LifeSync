// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/task_details.dart';
import 'package:flutter_todo_app/services/get_tasks.dart';
import 'package:flutter_todo_app/services/get_tasks_list.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  final user = FirebaseAuth.instance.currentUser;

  void goHome() {
    Navigator.pop(context);
  }

  List<String> docIDs = [];

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('Tasks')
        .where('userId', isEqualTo: user!.uid)
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach((document) {
            docIDs.add(document.reference.id);
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: goHome,
              icon: Icon(
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
      body: Expanded(
        child: FutureBuilder(
          future: getDocId(),
          builder: (context, snapshot) {
            return ListView.builder(
                itemCount: docIDs.length,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Card(
                      child: ListTile(
                        onTap: () async {
                          final taskData =
                              await GetTasks(documentId: docIDs[index])
                                  .getTaskData();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetails(taskData: taskData),
                            ),
                          );
                        },
                        tileColor: Colors.grey.shade200,
                        title: GetTaskList(documentId: docIDs[index]),
                      ),
                    ),
                  );
                }));
          },
        ),
      ),
    );
  }
}
