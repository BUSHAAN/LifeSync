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

    List<DateTime> calculateNextOccurrences(
        List<int> selectedWeekdays, DateTime startTime) {
      List<DateTime> occurrences = [];
      for (int weekday in selectedWeekdays) {
        // Calculate the difference between the desired weekday and today
        int daysToAdd = weekday - DateTime.now().weekday;
        if (daysToAdd < 0) {
          daysToAdd +=
              7; // Handle cases where the desired day is in the past week
        }
        // Calculate the next occurrence of the weekday
        DateTime occurrence = DateTime.now().add(Duration(days: daysToAdd));
        // Check if the event start time has already passed today
        if (weekday == DateTime.now().weekday &&
            DateTime.now().hour >= startTime.hour) {
          // If the event time has passed, move to the next occurrence
          occurrence = occurrence.add(const Duration(days: 7));
        }
        occurrences.add(occurrence);
      }
      return occurrences;
    }

Future<Map<String, dynamic>?> addEventDetails(Event event) async {
  // Prepare the list of occurrences
  Future<QueryDocumentSnapshot?> findBlockingEvent(
      DateTime startDateTime, DateTime endDateTime) async {
    var overlappingDailyItems = await FirebaseFirestore.instance
        .collection('DailyItems')
        .where('userId', isEqualTo: event.userId)
        .where('isEvent', isEqualTo: true)
        .where('startDateTime', isGreaterThanOrEqualTo: DateTime.now())
        .where('startDateTime', isLessThan: endDateTime)
        .where('endDateTime', isGreaterThan: startDateTime)
        .limit(1)
        .get();

    return overlappingDailyItems.docs.isNotEmpty
        ? overlappingDailyItems.docs.first
        : null;
  }

  List<DateTime> occurrences;
  if (event.frequency == "One-Time") {
    occurrences = [
      DateTime(
          event.startDate!.year,
          event.startDate!.month,
          event.startDate!.day,
          event.startTime!.hour,
          event.startTime!.minute)
    ];
  } else if (event.frequency == "Weekly") {
    occurrences =
        calculateNextOccurrences(event.selectedWeekdays!, event.startTime!);
  } else if (event.frequency == "Daily") {
    occurrences =
        calculateNextOccurrences([1, 2, 3, 4, 5, 6, 7], event.startTime!);
  } else {
    throw Exception("Invalid event frequency");
  }

  // First, check for overlaps for all occurrences
  for (DateTime occurrence in occurrences) {
    DateTime startDateTime = DateTime(occurrence.year, occurrence.month,
        occurrence.day, event.startTime!.hour, event.startTime!.minute);
    DateTime endDateTime = DateTime(occurrence.year, occurrence.month,
        occurrence.day, event.endTime!.hour, event.endTime!.minute);

    QueryDocumentSnapshot? blockingEvent =
        await findBlockingEvent(startDateTime, endDateTime);
    if (blockingEvent != null) {
      // Return the blocking event details as a map
      return {
        'hasConflict': true,
        'blockingEvent': blockingEvent,
      };
    }
  }

  // If no overlaps are found, add the event and daily items
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

  for (DateTime occurrence in occurrences) {
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

  // Return null if no conflicts are found
  return null;
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


Future<void> updateEvent(String docId, Event updatedEvent, BuildContext context) async {
  Future<QueryDocumentSnapshot?> findBlockingEvent(
    DateTime startDateTime, DateTime endDateTime, String docId) async {
  var overlappingDailyItems = await FirebaseFirestore.instance
      .collection('DailyItems')
      .where('userId', isEqualTo: updatedEvent.userId)
      .where('isEvent', isEqualTo: true)
      .where('startDateTime', isGreaterThanOrEqualTo: DateTime.now())
      .where('startDateTime', isLessThan: endDateTime)
      .where('endDateTime', isGreaterThan: startDateTime)
      .where('refId', isNotEqualTo: docId) // Ensure the current event is excluded
      .limit(1)
      .get();

  return overlappingDailyItems.docs.isNotEmpty
      ? overlappingDailyItems.docs.first
      : null;
}

  // Prepare the list of occurrences based on the event frequency
  List<DateTime> occurrences;
  if (updatedEvent.frequency == "One-Time") {
    occurrences = [
      DateTime(
          updatedEvent.startDate!.year,
          updatedEvent.startDate!.month,
          updatedEvent.startDate!.day,
          updatedEvent.startTime!.hour,
          updatedEvent.startTime!.minute)
    ];
  } else if (updatedEvent.frequency == "Weekly") {
    occurrences = calculateNextOccurrences(updatedEvent.selectedWeekdays!, updatedEvent.startTime!);
  } else if (updatedEvent.frequency == "Daily") {
    occurrences = calculateNextOccurrences([1, 2, 3, 4, 5, 6, 7], updatedEvent.startTime!);
  } else {
    throw Exception("Invalid event frequency");
  }

  // Check for overlaps for all occurrences
  for (DateTime occurrence in occurrences) {
    DateTime startDateTime = DateTime(occurrence.year, occurrence.month,
        occurrence.day, updatedEvent.startTime!.hour, updatedEvent.startTime!.minute);
    DateTime endDateTime = DateTime(occurrence.year, occurrence.month,
        occurrence.day, updatedEvent.endTime!.hour, updatedEvent.endTime!.minute);

    QueryDocumentSnapshot? blockingEvent =
        await findBlockingEvent(startDateTime, endDateTime, docId);
    if (blockingEvent != null) {
      // Show a dialog box with blocking event details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Event Conflict"),
            content: Text(
                "The event '${blockingEvent['itemName']}' scheduled on ${blockingEvent['startDateTime'].toDate()} conflicts with your updated event."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // Stop the function if there is a conflict
    }
  }

  // If no overlaps are found, update the event itself
  await FirebaseFirestore.instance.collection('Events').doc(docId).update({
    'userId': updatedEvent.userId,
    'eventName': updatedEvent.eventName,
    'startTime': updatedEvent.startTime,
    'endTime': updatedEvent.endTime,
    'startDate': updatedEvent.startDate,
  });

  // Fetch existing DailyItems for the event
  var existingDailyItems = await FirebaseFirestore.instance
      .collection('DailyItems')
      .where('refId', isEqualTo: docId)
      .get();

  // If the number of occurrences differs from the existing daily items, delete the old ones and create new ones
  if (existingDailyItems.docs.length != occurrences.length) {
    for (var element in existingDailyItems.docs) {
      await element.reference.delete();
    }

    for (DateTime occurrence in occurrences) {
      DateTime startDateTime = DateTime(occurrence.year, occurrence.month,
          occurrence.day, updatedEvent.startTime!.hour, updatedEvent.startTime!.minute);
      DateTime endDateTime = DateTime(occurrence.year, occurrence.month,
          occurrence.day, updatedEvent.endTime!.hour, updatedEvent.endTime!.minute);

      await FirebaseFirestore.instance.collection('DailyItems').add({
        "duration": endDateTime.difference(startDateTime).inHours,
        "endDateTime": endDateTime,
        "isEvent": true,
        "itemName": updatedEvent.eventName,
        "startDateTime": startDateTime,
        "userId": updatedEvent.userId,
        "refId": docId,
      });
    }
  } else {
    // Otherwise, update existing items
    for (int i = 0; i < occurrences.length; i++) {
      var existingItem = existingDailyItems.docs[i];
      DateTime occurrence = occurrences[i];
      DateTime startDateTime = DateTime(occurrence.year, occurrence.month,
          occurrence.day, updatedEvent.startTime!.hour, updatedEvent.startTime!.minute);
      DateTime endDateTime = DateTime(occurrence.year, occurrence.month,
          occurrence.day, updatedEvent.endTime!.hour, updatedEvent.endTime!.minute);

      await existingItem.reference.update({
        "duration": endDateTime.difference(startDateTime).inHours,
        "endDateTime": endDateTime,
        "isEvent": true,
        "itemName": updatedEvent.eventName,
        "startDateTime": startDateTime,
        "userId": updatedEvent.userId,
      });
    }
  }
}


// Helper method to find a blocking event


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
