// ignore_for_file: avoid_function_literals_in_foreach_calls, use_build_context_synchronously, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/add_task.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text(
            "All Tasks",
            style: (TextStyle(
              color: Colors.white,
            )),
          ),
          backgroundColor: Colors.blue.shade600,
        ),
        floatingActionButton: FloatingActionButton(
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 40,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTasksPage()),
            );
          },
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
                      title: Text(taskTitle),
                      trailing: Wrap(
                        spacing: 1,
                        children: [
                          IconButton(
                              onPressed: () async {
                                final taskData =
                                    await fireStoreService.getTaskData(docId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetails(
                                        taskData: taskData, documentId: docId),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_note)),
                          IconButton(
                              onPressed: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Are you sure?'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Do you want to permanently delete'),
                                        Text('"$taskTitle"'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (result == null || !result) {
                                  return;
                                }
                                setState(() {
                                  fireStoreService.deleteTask(docId);
                                });
                              },
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                    )),
                  );
                },
              );
            } else {
              return const Text("Loading....");
            }
          },
        ));
  }
}
