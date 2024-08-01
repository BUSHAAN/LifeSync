// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/daily_item.dart';
import 'package:flutter_todo_app/model/task.dart';
import 'package:flutter_todo_app/model/event.dart';

class FireStoreService {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection("Tasks");
  final CollectionReference events =
      FirebaseFirestore.instance.collection("Events");
  final CollectionReference dailyItems =
      FirebaseFirestore.instance.collection("DailyItems");

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
  }

  Future<void> deleteTask(String docId) async {
    await tasks.doc(docId).delete();
  }

  Future<void> addEventDetails(Event event) async {
    DocumentReference<Map<String, dynamic>> docRef =
        await FirebaseFirestore.instance.collection('Events').add({
      "userId": event.userId,
      "eventName": event.eventName,
      "startTime": event.startTime,
      "endTime": event.endTime,
      "frequency": event.frequency,
      "selectedWeekdays": event.selectedWeekdays,
      "startDate": event.startDate,
    });
    List<DateTime> calculateNextOccurrences(
        List<int> selectedWeekdays, DateTime startTime, DateTime now) {
      List<DateTime> occurrences = [];
      for (int weekday in selectedWeekdays) {
        // Calculate the difference between the desired weekday and today
        int daysToAdd = weekday - now.weekday;
        if (daysToAdd < 0) {
          daysToAdd +=
              7; // Handle cases where the desired day is in the past week
        }
        // Calculate the next occurrence of the weekday
        DateTime occurrence = now.add(Duration(days: daysToAdd));
        // Check if the event start time has already passed today
        if (weekday == now.weekday && now.hour >= startTime.hour) {
          // If the event time has passed, move to the next occurrence
          occurrence = occurrence.add(const Duration(days: 7));
        }
        occurrences.add(occurrence);
      }
      return occurrences;
    }
    if (event.frequency == "One-Time") {
      DateTime startDateTime = DateTime(
          event.startDate!.year,
          event.startDate!.month,
          event.startDate!.day,
          event.startTime!.hour,
          event.startTime!.minute);
      DateTime endDateTime = DateTime(
          event.startDate!.year,
          event.startDate!.month,
          event.startDate!.day,
          event.endTime!.hour,
          event.endTime!.minute);
      await FirebaseFirestore.instance.collection('DailyItems').add({
        "userId": event.userId,
        "itemName": event.eventName,
        "isEvent": true,
        "startDateTime": startDateTime,
        "endDateTime": endDateTime,
        "duration": event.endTime == null
            ? 0
            : event.endTime!.difference(event.startTime!).inHours,
        "refId": docRef.id,
      });
    } else if (event.frequency == "Weekly") {
      List<DateTime> nextOccurrences = calculateNextOccurrences(
          event.selectedWeekdays!, event.startTime!, DateTime.now());
      for (DateTime occurrence in nextOccurrences) {
        DateTime startDateTime = DateTime(occurrence.year, occurrence.month,
            occurrence.day, event.startTime!.hour, event.startTime!.minute);
        DateTime endDateTime = DateTime(occurrence.year, occurrence.month,
            occurrence.day, event.endTime!.hour, event.endTime!.minute);
        await FirebaseFirestore.instance.collection('DailyItems').add({
          "userId": event.userId,
          "itemName": event.eventName,
          "isEvent": true,
          "startDateTime": startDateTime,
          "endDateTime": endDateTime,
          "duration": event.endTime == null
              ? 0
              : event.endTime!.difference(event.startTime!).inHours,
          "refId": docRef.id,
        });
      }
    }else if (event.frequency == "Daily"){
      List<DateTime> nextOccurrences = calculateNextOccurrences(
          [1,2,3,4,5,6,7], event.startTime!, DateTime.now());
      for (DateTime occurrence in nextOccurrences) {
        DateTime startDateTime = DateTime(occurrence.year, occurrence.month,
            occurrence.day, event.startTime!.hour, event.startTime!.minute);
        DateTime endDateTime = DateTime(occurrence.year, occurrence.month,
            occurrence.day, event.endTime!.hour, event.endTime!.minute);
        await FirebaseFirestore.instance.collection('DailyItems').add({
          "userId": event.userId,
          "itemName": event.eventName,
          "isEvent": true,
          "startDateTime": startDateTime,
          "endDateTime": endDateTime,
          "duration": event.endTime == null
              ? 0
              : event.endTime!.difference(event.startTime!).inHours,
          "refId": docRef.id,
        });
      }
    }
  }

  Stream<QuerySnapshot> getEventStream(userId) {
    final eventStream = events
        .where('userId', isEqualTo: userId)
        //.orderBy('startDate', descending: true)
        .snapshots();
    return eventStream;
  }

  Future<Map<String, dynamic>> getEventData(documentId) async {
    final docRef =
        FirebaseFirestore.instance.collection('Events').doc(documentId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      return {}; // Return an empty map if document doesn't exist
    }
  }

  Future<void> updateEvent(
      String docId, Map<String, dynamic> updatedEvent) async {
    await events.doc(docId).update({
      'userId': updatedEvent['userId'], // Assuming you have a userId field
      'eventName': updatedEvent['eventName'],
      'startTime': updatedEvent['startTime'],
      'endTime': updatedEvent['endTime'],
      'frequency': updatedEvent['frequency'],
      'selectedWeekdays': updatedEvent['selectedWeekdays'],
    });

    DateTime startDateTime = DateTime(
        updatedEvent['startDate'].year,
        updatedEvent['startDate'].month,
        updatedEvent['startDate'].day,
        updatedEvent['startTime'].hour,
        updatedEvent['startTime'].minute);
    DateTime endDateTime = DateTime(
        updatedEvent['startDate'].year,
        updatedEvent['startDate'].month,
        updatedEvent['startDate'].day,
        updatedEvent['startTime'].hour,
        updatedEvent['startTime'].minute);
    await dailyItems.where('refId', isEqualTo: docId).get().then((value) {
      for (var element in value.docs) {
        element.reference.update({
          "duration": endDateTime.difference(startDateTime).inHours,
          "endDateTime": endDateTime,
          "isEvent": true,
          "itemName": updatedEvent['eventName'],
          "startDateTime": startDateTime,
          "userId": updatedEvent['userId'],
        });
      }
    });
  }

  Future<void> deleteEvent(String docId) async {
    await events.doc(docId).delete();
    QuerySnapshot querySnapshot =
        await dailyItems.where('refId', isEqualTo: docId).get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addDailyItemDetails(
    DailyItem dailyItem,
  ) async {
    await FirebaseFirestore.instance.collection('Tasks').add({
      "itemName": dailyItem.itemName,
      "isEvent": dailyItem.isEvent,
      "startDateTime": dailyItem.from,
      "endDateTime": dailyItem.to,
      "userId": dailyItem.userId,
    });
  }

  Stream<QuerySnapshot> getDailyItemStream(userId) {
    final dailyItemStream = dailyItems
        .where('userId', isEqualTo: userId)
        //.orderBy('startDate', descending: true)
        .snapshots();
    return dailyItemStream;
  }

  Future<void> updateDailyItem(
      String docId, Map<String, dynamic> updatedDailyItem) async {
    await events.doc(docId).update({
      'duration': updatedDailyItem['duration'],
      'endDateTime': updatedDailyItem['endDateTime'],
      'isEvent': updatedDailyItem['isEvent'],
      'itemName': updatedDailyItem['itemName'],
      'startDateTime': updatedDailyItem['startDateTime'],
      'refId': updatedDailyItem['refId'],
      'userId': updatedDailyItem['userId'],
    });
  }
}
