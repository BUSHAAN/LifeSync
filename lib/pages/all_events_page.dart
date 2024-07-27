// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/add_event.dart';
import 'package:flutter_todo_app/pages/event_details.dart';
import 'package:flutter_todo_app/services/firestore.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final user = FirebaseAuth.instance.currentUser;
  FireStoreService fireStoreService = FireStoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "All Events",
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
            MaterialPageRoute(builder: (context) => AddEventPage()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getEventStream(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List eventList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: eventList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = eventList[index];
                  String docId = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  String eventTitle = data['eventName'];
                  return Card(
                    child: ListTile(title: Text(eventTitle),trailing: Wrap(
                      spacing: 1,
                        children: [
                          IconButton(
                              onPressed: () async {
                                final eventData =
                                    await fireStoreService.getEventData(docId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetails(
                                        eventData: eventData, documentId: docId),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Do you want to permanently delete'),
                                        Text('"$eventTitle"'),
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
                                  fireStoreService.deleteEvent(docId);
                                });
                              },
                              icon: const Icon(Icons.delete))
                        ],
                      ),),
                  );
                });
          } else {
            return Text("Loading....");
          }
        },
      ),
    );
  }
}
