// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/daily_item.dart';
import 'package:flutter_todo_app/model/schedules.dart';
import 'package:flutter_todo_app/model/task.dart';
import 'package:flutter_todo_app/model/event.dart';
import 'package:flutter_todo_app/pages/scheduling_section.dart';

class FireStoreService {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection("Tasks");
  final CollectionReference events =
      FirebaseFirestore.instance.collection("Events");
  final CollectionReference dailyItems =
      FirebaseFirestore.instance.collection("DailyItems");

  Future<void> addTaskDetails(Task task) async {
    // Add the task to the "Tasks" collection
    DocumentReference<Map<String, dynamic>> taskRef =
        await FirebaseFirestore.instance.collection("Tasks").add({
      "userId": task.userId,
      "taskName": task.taskName,
      "duration": task.duration,
      "allowSplitting": task.allowSplitting,
      "maxChunkTime": task.maxChunkTime,
      "deadlineType": task.deadlineType,
      "deadline": task.deadline,
      "startDate": task.startDate,
      "schedule": task.schedule,
      "isDone": task.isDone,
    });

    // Get the schedule times (e.g., "Evening" -> [16, 21] for 4pm to 9pm)
    List<int> scheduleTimes = schedules[task.schedule] ?? [16, 21];
    int startHour = scheduleTimes[0]; // Start hour of the time slot (e.g., 4pm)
    int endHour = scheduleTimes[1]; // End hour of the time slot (e.g., 9pm)

    // Initialize variables for tracking the current date and remaining duration
    DateTime currentDate = task.startDate!;
    int remainingDuration =
        task.duration!.toInt(); // Total duration of the task in hours
    int chunkTime =
        (task.maxChunkTime ?? remainingDuration).toInt(); // Max chunk time

    // Loop to split the task into chunks (subtasks) if allowed
    while (remainingDuration > 0) {
      // Determine the duration of the current chunk (subtask)
      int currentChunkTime =
          (remainingDuration >= chunkTime) ? chunkTime : remainingDuration;

      // Set the start and end times for the current chunk within the schedule
      DateTime startDateTime = DateTime(
          currentDate.year, currentDate.month, currentDate.day, startHour);
      DateTime endDateTime =
          startDateTime.add(Duration(hours: currentChunkTime));

      // Adjust the chunk to fit within the schedule's end time
      if (endDateTime.hour > endHour) {
        endDateTime = DateTime(
            currentDate.year, currentDate.month, currentDate.day, endHour);
        currentChunkTime = endDateTime.difference(startDateTime).inHours;
      }

      // Check for scheduling conflicts and find the next available slot if needed
      DateTime nextAvailableStart = await _findNextAvailableTimeSlot(
        task.userId,
        startDateTime,
        currentChunkTime, // Pass the chunk duration for conflict checking
      );
      startDateTime = nextAvailableStart;
      endDateTime = startDateTime.add(Duration(hours: currentChunkTime));

      // Add the subtask (daily item) to the "DailyItems" collection
      await FirebaseFirestore.instance.collection("DailyItems").add({
        "userId": task.userId,
        "itemName": task.taskName,
        "isEvent": false, // It's a task, not an event
        "startDateTime": startDateTime,
        "endDateTime": endDateTime,
        "duration": currentChunkTime,
        "refId": taskRef.id,
        "isCompleted": false // Reference to the main task
      });

      // Update the remaining duration and move to the next day for the next chunk
      remainingDuration -= currentChunkTime;
      currentDate = currentDate.add(Duration(days: 1)); // Move to the next day
    }
  }

// Helper function to check for conflicts
  Future<DocumentSnapshot?> _getConflictingDailyItem(
      String userId, DateTime startDateTime, DateTime endDateTime) async {
    var conflictQuery = dailyItems
        .where('userId', isEqualTo: userId)
        .where('startDateTime', isLessThan: endDateTime)
        .where('endDateTime', isGreaterThan: startDateTime)
        .limit(1); // We only need to know if any conflict exists

    var conflictSnapshot = await conflictQuery.get();
    if (conflictSnapshot.docs.isNotEmpty) {
      return conflictSnapshot.docs.first;
    } else {
      return null;
    }
  }

// Helper function to find the next available time slot in case of conflicts
  Future<DateTime> _findNextAvailableTimeSlot(
      String userId, DateTime startDateTime, int chunkDuration) async {
    DateTime proposedStart = startDateTime;

    while (true) {
      DateTime proposedEnd = proposedStart.add(Duration(hours: chunkDuration));

      // Check if this new proposed time slot conflicts with anything
      DocumentSnapshot? conflict = await _getConflictingDailyItem(
        userId,
        proposedStart,
        proposedEnd,
      );

      if (conflict == null) {
        // If no conflict is found, return the proposed start time
        return proposedStart;
      } else {
        // If there is a conflict, move the start time to after the conflicting event
        proposedStart = (conflict['endDateTime'] as Timestamp).toDate();
      }
    }
  }


  Stream<QuerySnapshot> getTasksStream(userId) {
    final tasksStream = tasks
        .where('userId', isEqualTo: userId)
        //.orderBy('startDate', descending: true)
        .snapshots();
    return tasksStream;
  }

  Future<Map<String, dynamic>> getTaskData(documentId) async {
    final docRef = tasks.doc(documentId);
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
      'deadlineType': updatedTask['deadlineType'],
      'deadline': updatedTask['deadline'], // Convert to ISO 8601 format
      'startDate': updatedTask['startDate'], // Convert to ISO 8601 format
      'schedule': updatedTask['schedule'],
      'isDone': updatedTask['isDone'], // Assuming you have an isDone field
    });
  }

  Future<void> deleteTask(String docId) async {
    await tasks.doc(docId).delete();
    QuerySnapshot querySnapshot =
        await dailyItems.where('refId', isEqualTo: docId).get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
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

      // Calculate the first occurrence of the weekday in the first week
      DateTime firstOccurrence = DateTime.now().add(Duration(days: daysToAdd));

      // Check if the event start time has already passed today
      if (weekday == DateTime.now().weekday &&
          DateTime.now().hour >= startTime.hour) {
        // If the event time has passed, move to the next occurrence
        firstOccurrence = firstOccurrence.add(const Duration(days: 7));
      }

      // Add first occurrence
      occurrences.add(firstOccurrence);

      // Calculate and add the second occurrence (week after the first occurrence)
      DateTime secondOccurrence = firstOccurrence.add(const Duration(days: 7));
      occurrences.add(secondOccurrence);
    }
    return occurrences;
  }

  Future<Map<String, dynamic>?> addEventDetails(Event event) async {
    // Prepare the list of occurrences based on event frequency
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

    QueryDocumentSnapshot? conflictResult = await _checkForConflicts(event);
    if (conflictResult != null) {
      // If a conflict is found, return the conflicting event
      return {
        'hasConflict': true,
        'blockingEvent': conflictResult,
      };
    }

    // If no overlaps are found, add the event to Events collection
    DocumentReference<Map<String, dynamic>> docRef =
        await FirebaseFirestore.instance.collection("Events").add({
      "userId": event.userId,
      "eventName": event.eventName,
      "startTime": event.startTime,
      "endTime": event.endTime,
      "frequency": event.frequency,
      "selectedWeekdays": event.selectedWeekdays,
      "startDate": event.startDate,
    });

    // Add corresponding daily items for each occurrence
    for (DateTime occurrence in occurrences) {
      DateTime startDateTime = DateTime(occurrence.year, occurrence.month,
          occurrence.day, event.startTime!.hour, event.startTime!.minute);
      DateTime endDateTime = DateTime(occurrence.year, occurrence.month,
          occurrence.day, event.endTime!.hour, event.endTime!.minute);

      // Check for conflicts with other DailyItems for this occurrence
      bool conflictResolved = await _handleDailyItemConflictsAndReschedule(
          event.userId, startDateTime, endDateTime, event.eventName);

      if (conflictResolved) {
        // No conflicts or conflicts resolved – Add the DailyItem
        await dailyItems.add({
          "userId": event.userId,
          "itemName": event.eventName,
          "isEvent": true,
          "startDateTime": startDateTime,
          "endDateTime": endDateTime,
          "duration": event.endTime == null
              ? 0
              : event.endTime!.difference(event.startTime!).inHours,
          "refId": docRef.id,
          "isCompleted": false,
        });
      } else {
        // If conflicts couldn't be resolved, return with conflict details
        return {
          'hasConflict': true,
          'blockingEvent': {
            'startDateTime': startDateTime,
            'endDateTime': endDateTime
          },
        };
      }
    }

    // Return null if no conflicts are found
    return null;
  }

  Future<bool> _handleDailyItemConflictsAndReschedule(String userId,
      DateTime startDateTime, DateTime endDateTime, String eventName) async {
    // Query daily items that might conflict with this occurrence
    var taskQuery = dailyItems
        .where('userId', isEqualTo: userId)
        .where('startDateTime', isLessThan: endDateTime)
        .where('endDateTime', isGreaterThan: startDateTime)
        .orderBy('startDateTime');

    var taskSnapshot = await taskQuery.get();

    // If there are no conflicts, return true (no rescheduling needed)
    if (taskSnapshot.docs.isEmpty) {
      return true;
    }

    // Iterate over conflicting tasks and reschedule them if needed
    for (var taskDoc in taskSnapshot.docs) {
      var taskData = taskDoc.data() as Map<String, dynamic>;
      DateTime taskStart = (taskData['startDateTime'] as Timestamp).toDate();
      DateTime taskEnd = (taskData['endDateTime'] as Timestamp).toDate();
      int taskDuration = taskEnd.hour - taskStart.hour; // Task duration

      // Reschedule the conflicting task (implement your rescheduling logic)
      await _rescheduleTask(taskDoc.id, endDateTime, userId, taskDuration);
    }

    // After rescheduling, return true
    return true;
  }

  Future<void> _rescheduleTask(
      String dailyItemId, // ID of the task to reschedule
      DateTime eventEndTime, // End time of the new event
      String userId, // User ID for querying tasks
      int taskDurationInHours // Duration of the task to be rescheduled
      ) async {
    DateTime proposedStart = eventEndTime;
    DateTime proposedEnd =
        proposedStart.add(Duration(hours: taskDurationInHours));

    while (true) {
      // Check for conflicts excluding the task we're rescheduling
      DocumentSnapshot? conflictingItem = await _getConflictingTask(
          userId, proposedStart, proposedEnd,
          excludeTaskId:
              dailyItemId // Exclude the task itself from conflict check
          );

      if (conflictingItem == null) {
        // No conflicts found, we can reschedule the task here
        await dailyItems.doc(dailyItemId).update({
          "startDateTime": proposedStart,
          "endDateTime": proposedEnd,
          "duration": taskDurationInHours,
        });
        print(
            "Task rescheduled to start at $proposedStart and end at $proposedEnd.");
        return; // Exit after successful reschedule
      } else {
        // Conflict found, move to after the conflicting task/event's end time and check again
        proposedStart = (conflictingItem['endDateTime'] as Timestamp).toDate();
        proposedEnd = proposedStart.add(Duration(hours: taskDurationInHours));
      }
    }
  }

// Helper function to check for conflicts, with the ability to exclude a specific task by ID
  Future<DocumentSnapshot?> _getConflictingTask(
      String userId, DateTime startDateTime, DateTime endDateTime,
      {required String
          excludeTaskId} // ID of the task to exclude from conflict checking
      ) async {
    var conflictQuery = dailyItems
        .where('userId', isEqualTo: userId)
        .where('startDateTime', isLessThan: endDateTime)
        .where('endDateTime', isGreaterThan: startDateTime)
        .where(FieldPath.documentId,
            isNotEqualTo: excludeTaskId) // Exclude the task being rescheduled
        .limit(1); // Only need one conflicting item to know there's a conflict

    var conflictSnapshot = await conflictQuery.get();
    if (conflictSnapshot.docs.isNotEmpty) {
      return conflictSnapshot.docs.first;
    } else {
      return null;
    }
  }

//Conflict checking helper function
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _checkForConflicts(
      Event newEvent,
      {String? excludeEventId}) async {
    // Helper function to get conflicts based on query
    Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getConflictingEvent(
        Query<Map<String, dynamic>> query) async {
      var querySnapshot = await query.get();
      for (var doc in querySnapshot.docs) {
        if (excludeEventId == null || doc.id != excludeEventId) {
          return doc;
        }
      }
      return null;
    }

    // If the event is One-Time
    if (newEvent.frequency == 'One-Time') {
      // Check for conflicts with daily events
      var dailyConflictsQuery = events
              .where('userId', isEqualTo: newEvent.userId)
              .where('frequency', isEqualTo: 'Daily')
              .where('startTime', isLessThan: newEvent.endTime)
              .where('endTime', isGreaterThan: newEvent.startTime)
          as Query<Map<String, dynamic>>;

      var dailyConflict = await getConflictingEvent(dailyConflictsQuery);
      if (dailyConflict != null) return dailyConflict;

      // Check for conflicts with weekly events
      int eventWeekday = newEvent.startDate!.weekday;
      var weeklyConflictsQuery = events
              .where('userId', isEqualTo: newEvent.userId)
              .where('frequency', isEqualTo: 'Weekly')
              .where('selectedWeekdays', arrayContains: eventWeekday)
              .where('startTime', isLessThan: newEvent.endTime)
              .where('endTime', isGreaterThan: newEvent.startTime)
          as Query<Map<String, dynamic>>;

      var weeklyConflict = await getConflictingEvent(weeklyConflictsQuery);
      if (weeklyConflict != null) return weeklyConflict;

      // Check for conflicts with other one-time events
      var oneTimeConflictsQuery = events
              .where('userId', isEqualTo: newEvent.userId)
              .where('frequency', isEqualTo: 'One-Time')
              .where('startDate', isEqualTo: newEvent.startDate)
              .where('startTime', isLessThan: newEvent.endTime)
              .where('endTime', isGreaterThan: newEvent.startTime)
          as Query<Map<String, dynamic>>;

      var oneTimeConflict = await getConflictingEvent(oneTimeConflictsQuery);
      if (oneTimeConflict != null) return oneTimeConflict;
    }

    // If the event is Weekly
    if (newEvent.frequency == 'Weekly') {
      // Check for conflicts with daily events
      var dailyConflictsQuery = events
              .where('userId', isEqualTo: newEvent.userId)
              .where('frequency', isEqualTo: 'Daily')
              .where('startTime', isLessThan: newEvent.endTime)
              .where('endTime', isGreaterThan: newEvent.startTime)
          as Query<Map<String, dynamic>>;

      var dailyConflict = await getConflictingEvent(dailyConflictsQuery);
      if (dailyConflict != null) return dailyConflict;

      // Check for conflicts with other weekly events
      for (int weekday in newEvent.selectedWeekdays!) {
        var weeklyConflictsQuery = events
                .where('userId', isEqualTo: newEvent.userId)
                .where('frequency', isEqualTo: 'Weekly')
                .where('selectedWeekdays', arrayContains: weekday)
                .where('startTime', isLessThan: newEvent.endTime)
                .where('endTime', isGreaterThan: newEvent.startTime)
            as Query<Map<String, dynamic>>;

        var weeklyConflict = await getConflictingEvent(weeklyConflictsQuery);
        if (weeklyConflict != null) return weeklyConflict;
      }

      // Check for conflicts with one-time events
      var oneTimeConflictsQuery = events
              .where('userId', isEqualTo: newEvent.userId)
              .where('frequency', isEqualTo: 'One-Time')
              .where('startTime', isLessThan: newEvent.endTime)
              .where('endTime', isGreaterThan: newEvent.startTime)
          as Query<Map<String, dynamic>>;

      var oneTimeConflict = await getConflictingEvent(oneTimeConflictsQuery);
      if (oneTimeConflict != null) {
        DateTime eventDay =
            (oneTimeConflict['startDate'] as Timestamp).toDate();
        if (newEvent.selectedWeekdays!.contains(eventDay.weekday)) {
          return oneTimeConflict;
        }
      }
    }

    // If the event is Daily
    if (newEvent.frequency == 'Daily') {
      // Check for conflicts with any existing event
      var conflictsQuery = events
              .where('userId', isEqualTo: newEvent.userId)
              .where('startTime', isLessThan: newEvent.endTime)
              .where('endTime', isGreaterThan: newEvent.startTime)
          as Query<Map<String, dynamic>>;

      var conflict = await getConflictingEvent(conflictsQuery);
      if (conflict != null) return conflict;
    }

    return null; // No conflict found
  }

// Helper function to get the date of the next occurrence of a given weekday
  DateTime _getDateForNextWeekday(int weekday) {
    DateTime today = DateTime.now();
    int daysToAdd = (weekday - today.weekday) % 7;
    return today.add(Duration(days: daysToAdd));
  }

  Stream<QuerySnapshot> getEventStream(userId) {
    final eventStream = events
        .where('userId', isEqualTo: userId)
        //.orderBy('startDate', descending: true)
        .snapshots();
    return eventStream;
  }

  Future<Map<String, dynamic>> getEventData(documentId) async {
    final docRef = events.doc(documentId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      return {}; // Return an empty map if document doesn't exist
    }
  }

  Future<void> updateEvent(
      String docId, Event updatedEvent, BuildContext context) async {
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
      occurrences = calculateNextOccurrences(
          updatedEvent.selectedWeekdays!, updatedEvent.startTime!);
    } else if (updatedEvent.frequency == "Daily") {
      occurrences = calculateNextOccurrences(
          [1, 2, 3, 4, 5, 6, 7], updatedEvent.startTime!);
    } else {
      throw Exception("Invalid event frequency");
    }

    // Check for overlaps for all occurrences

    QueryDocumentSnapshot? blockingEvent =
        await _checkForConflicts(updatedEvent, excludeEventId: docId);
    if (blockingEvent != null) {
      // Show a dialog box with blocking event details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Event Conflict"),
            content: blockingEvent['frequency'] == 'One-Time'
                ? Text(
                    "The event '${blockingEvent['eventName']}' scheduled on ${blockingEvent['startDate'].toDate().day}-${blockingEvent['startDate'].toDate().month}-${blockingEvent['startDate'].toDate().year} conflicts with your new event.")
                : blockingEvent['frequency'] == 'Weekly'
                    ? Text(
                        "The event '${blockingEvent['eventName']}' scheduled weekly on ${blockingEvent['selectedWeekdays'].map((weekday) {
                        switch (weekday) {
                          case DateTime.monday:
                            return 'Monday';
                          case DateTime.tuesday:
                            return 'Tuesday';
                          case DateTime.wednesday:
                            return 'Wednesday';
                          case DateTime.thursday:
                            return 'Thursday';
                          case DateTime.friday:
                            return 'Friday';
                          case DateTime.saturday:
                            return 'Saturday';
                          case DateTime.sunday:
                            return 'Sunday';
                          default:
                            return '';
                        }
                      }).join(', ')} at ${blockingEvent['startTime'].toDate().hour}:${blockingEvent['startTime'].toDate().minute.toString().padLeft(2, '0')} conflicts with your new event.")
                    : Text(
                        "The event '${blockingEvent['eventName']}' scheduled daily at ${blockingEvent['startTime'].toDate().hour}:${blockingEvent['startTime'].toDate().minute.toString().padLeft(2, '0')} conflicts with your new event."),
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
    Navigator.of(context).pop();
    // If no overlaps are found, update the event itself
    await events.doc(docId).update({
      'userId': updatedEvent.userId,
      'eventName': updatedEvent.eventName,
      'startTime': updatedEvent.startTime,
      'endTime': updatedEvent.endTime,
      'startDate': updatedEvent.startDate,
    });

    // Fetch existing DailyItems for the event
    var existingDailyItems =
        await dailyItems.where('refId', isEqualTo: docId).get();

    // If the number of occurrences differs from the existing daily items, delete the old ones and create new ones
    if (existingDailyItems.docs.length != occurrences.length) {
      for (var element in existingDailyItems.docs) {
        await element.reference.delete();
      }

      for (DateTime occurrence in occurrences) {
        DateTime startDateTime = DateTime(
            occurrence.year,
            occurrence.month,
            occurrence.day,
            updatedEvent.startTime!.hour,
            updatedEvent.startTime!.minute);
        DateTime endDateTime = DateTime(
            occurrence.year,
            occurrence.month,
            occurrence.day,
            updatedEvent.endTime!.hour,
            updatedEvent.endTime!.minute);

        await dailyItems.add({
          "duration": endDateTime.difference(startDateTime).inHours,
          "endDateTime": endDateTime,
          "isEvent": true,
          "itemName": updatedEvent.eventName,
          "startDateTime": startDateTime,
          "userId": updatedEvent.userId,
          "refId": docId,
          "isCompleted": false,
        });
      }
    } else {
      // Otherwise, update existing items
      for (int i = 0; i < occurrences.length; i++) {
        var existingItem = existingDailyItems.docs[i];
        DateTime occurrence = occurrences[i];
        DateTime startDateTime = DateTime(
            occurrence.year,
            occurrence.month,
            occurrence.day,
            updatedEvent.startTime!.hour,
            updatedEvent.startTime!.minute);
        DateTime endDateTime = DateTime(
            occurrence.year,
            occurrence.month,
            occurrence.day,
            updatedEvent.endTime!.hour,
            updatedEvent.endTime!.minute);

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
    await tasks.add({
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
    await dailyItems.doc(docId).update({
      'duration': updatedDailyItem['duration'],
      'endDateTime': updatedDailyItem['endDateTime'],
      'isEvent': updatedDailyItem['isEvent'],
      'itemName': updatedDailyItem['itemName'],
      'startDateTime': updatedDailyItem['startDateTime'],
      'refId': updatedDailyItem['refId'],
      'userId': updatedDailyItem['userId'],
      'isCompleted': updatedDailyItem['isCompleted'],
    });
  }

  Future<List<DocumentSnapshot>> getDailyItemsForTask(
      String taskId, String userId) async {
    final querySnapshot = await dailyItems
        .where('userId', isEqualTo: userId)
        .where('refId', isEqualTo: taskId)
        .where('isEvent', isEqualTo: false)
        .get();

    // Return a list of documents related to the task
    return querySnapshot.docs;
  }

  void checkAndHandleExpiredTasks(BuildContext context, String userId) async {
    print("Checking for expired tasks...");
    DateTime now = DateTime.now();

    // Query Firestore for tasks where endDateTime is before now and isCompleted is false
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('DailyItems')
        .where('endDateTime', isLessThan: now)
        .where('isCompleted', isEqualTo: false)
        .get();

    List<DocumentSnapshot> documents = querySnapshot.docs;

    for (var doc in documents) {
      Map<String, dynamic> dailyItem = doc.data() as Map<String, dynamic>;

      // Call method to handle the expired task
      await SchedulingSection()
          .showCompletionOrRescheduleDialog(context, dailyItem, doc.id, userId);
    }
  }
}
