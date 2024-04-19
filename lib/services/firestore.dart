// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo_app/model/Task.dart';
import 'package:flutter_todo_app/model/event.dart';

class FireStoreService {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection("Tasks");
  final CollectionReference events =
      FirebaseFirestore.instance.collection("Events");

  Future<void> addTaskDetails(
    Task task,
  ) async {
    await FirebaseFirestore.instance.collection('Tasks').add({
      "userId": task.userId,
      "taskName": task.taskName,
      "duration": task.duration,
      "allowSplitting": task.allowSplitting,
      "maxChunkTime": task.maxChunkTime,
      "priority": task.priority,
      "deadlineType": task.deadlineType,
      "deadline": task.deadline,
      "startDate": task.startDate,
      "schedule": task.schedule,
    });
  }

  Stream<QuerySnapshot> getTasksStream(userId) {
    final tasksStream = tasks
        .where('userId', isEqualTo: userId)
        //.orderBy('startDate', descending: true)
        .snapshots();
    return tasksStream;
  }

  Future<Map<String, dynamic>> getTaskData(documentId) async {
    final docRef =
        FirebaseFirestore.instance.collection('Tasks').doc(documentId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      //print('No task found for document ID: $documentId');
      return {}; // Return an empty map if document doesn't exist
    }
  }

  Future<void> updateTask(
      String docId, Map<String, dynamic> updatedTask) async {
    await tasks.doc(docId).update({
      'userId': updatedTask['userId'], // Assuming you have a userId field
      'taskName': updatedTask['taskName'],
      'duration': updatedTask['duration'],
      'allowSplitting': updatedTask['allowSplitting'],
      'maxChunkTime': updatedTask['maxChunkTime'],
      'priority': updatedTask['priority'],
      'deadlineType': updatedTask['deadlineType'],
      'deadline': updatedTask['deadline'], // Convert to ISO 8601 format
      'startDate': updatedTask['startDate'], // Convert to ISO 8601 format
      'schedule': updatedTask['schedule'],
      'isDone': updatedTask['isDone'], // Assuming you have an isDone field
    });
    //print(updatedTask.priority);
  }

  Future<void> deleteTask(String docId) async {
    await tasks.doc(docId).delete();
  }

  Future<void> addEventDetails(
    Event event,
  ) async {
    await FirebaseFirestore.instance.collection('Events').add({
      "userId": event.userId,
      "eventName": event.eventName,
      "startTime": event.startTime,
      "endTime": event.endTime,
      "frequency": event.frequency,
      "selectedWeekdays": event.selectedWeekdays
    });
  }

    Stream<QuerySnapshot> getEventStream(userId) {
    final eventStream = events
        .where('userId', isEqualTo: userId)
        //.orderBy('startDate', descending: true)
        .snapshots();
    return eventStream;
  }

    Future<void> deleteEvent(String docId) async {
    await events.doc(docId).delete();
  }
}
