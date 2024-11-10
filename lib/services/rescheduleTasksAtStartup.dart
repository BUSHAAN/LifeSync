import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo_app/model/schedules.dart';

class Rescheduletasksatstartup {
    final CollectionReference tasks =
      FirebaseFirestore.instance.collection("Tasks");
  final CollectionReference events =
      FirebaseFirestore.instance.collection("Events");
  final CollectionReference dailyItems =
      FirebaseFirestore.instance.collection("DailyItems");

      Future<void> rescheduleDailyItem(String dailyItemId) async {
  // Retrieve the DailyItem from Firestore
  DocumentSnapshot<Map<String, dynamic>> dailyItemSnapshot =
      await FirebaseFirestore.instance
          .collection("DailyItems")
          .doc(dailyItemId)
          .get();
  Map<String, dynamic> dailyItemData = dailyItemSnapshot.data()!;

  // Get the task associated with the DailyItem
  String taskId = dailyItemData["refId"];
  DocumentSnapshot<Map<String, dynamic>> taskSnapshot =
      await FirebaseFirestore.instance.collection("Tasks").doc(taskId).get();
  Map<String, dynamic> taskData = taskSnapshot.data()!;

  String schedule = taskData["schedule"];
  int dailyItemDuration = dailyItemData["duration"]; // In hours

  // Get the schedule times (e.g., Morning -> [7, 12])
  List<int> scheduleTimes = schedules[schedule] ?? [7, 12];
  int startHour = scheduleTimes[0];
  int endHour = scheduleTimes[1];

  // Check if we can schedule today (within the remaining window)
  DateTime now = DateTime.now();
  if (now.hour >= startHour && now.hour < endHour) {
    // We are still in today's time window, so we can try scheduling today
    startHour = now.hour + 1; // Start from the current hour +1
    DateTime todayStartTime = DateTime(now.year, now.month, now.day, startHour);
    await _scheduleDailyItem(dailyItemId, taskId, dailyItemDuration, todayStartTime, startHour, endHour);
  } else {
    // Today’s window is passed, move to the next available day
    DateTime nextDay = now.add(Duration(days: 1));
    await _findNextAvailableTimeSlotAndSchedule(dailyItemId, taskId, dailyItemDuration, nextDay, schedule);
  }
}

// Scheduling Helper Function
Future<void> _scheduleDailyItem(
    String dailyItemId,
    String taskId,
    int dailyItemDuration,
    DateTime startTime,
    int startHour,
    int endHour) async {

  DateTime startDateTime = startTime;
  DateTime endDateTime = startDateTime.add(Duration(hours: dailyItemDuration));

  // Check for conflicts in the current time slot
  while (startDateTime.hour + dailyItemDuration <= endHour) {
    bool hasConflict = await _hasConflictingDailyItem(
      taskId,
      startDateTime,
      endDateTime,
    );

    if (!hasConflict) {
      // If no conflict, reschedule the DailyItem
      await FirebaseFirestore.instance
          .collection("DailyItems")
          .doc(dailyItemId)
          .update({
        "startDateTime": startDateTime,
        "endDateTime": endDateTime,
      });
      return;
    }

    // Move to the next possible time slot after the conflict
    startDateTime = endDateTime;
    endDateTime = startDateTime.add(Duration(hours: dailyItemDuration));

    if (endDateTime.hour > endHour) {
      break; // End of this time window, try the next day
    }
  }
}

// Helper function to find the next available time slot on subsequent days
Future<void> _findNextAvailableTimeSlotAndSchedule(
    String dailyItemId,
    String taskId,
    int dailyItemDuration,
    DateTime currentDate,
    String schedule) async {

  List<int> scheduleTimes = schedules[schedule] ?? [7, 12];
  int startHour = scheduleTimes[0];
  int endHour = scheduleTimes[1];

  DateTime proposedStartDate = DateTime(currentDate.year, currentDate.month, currentDate.day, startHour);

  while (true) {
    // Make sure no other DailyItem of the same task is already scheduled for this day
    bool alreadyScheduledToday = await _isTaskScheduledOnDay(taskId, currentDate);
    if (!alreadyScheduledToday) {
      await _scheduleDailyItem(dailyItemId, taskId, dailyItemDuration, proposedStartDate, startHour, endHour);
      return;
    }

    // Move to the next day if today's time window is unavailable
    currentDate = currentDate.add(Duration(days: 1));
    proposedStartDate = DateTime(currentDate.year, currentDate.month, currentDate.day, startHour);
  }
}

// Helper function to check for conflicts
Future<bool> _hasConflictingDailyItem(
    String taskId, DateTime startDateTime, DateTime endDateTime) async {
  var conflictQuery = dailyItems
      .where('startDateTime', isLessThan: endDateTime)
      .where('endDateTime', isGreaterThan: startDateTime)
      .limit(1);

  var conflictSnapshot = await conflictQuery.get();
  return conflictSnapshot.docs.isNotEmpty;
}

// Helper function to check if a task is already scheduled on a specific day
Future<bool> _isTaskScheduledOnDay(String taskId, DateTime date) async {
  var scheduledQuery = dailyItems
      .where('refId', isEqualTo: taskId)
      .where('startDateTime', isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day))
      .where('startDateTime', isLessThan: DateTime(date.year, date.month, date.day).add(Duration(days: 1)))
      .limit(1);

  var scheduledSnapshot = await scheduledQuery.get();
  return scheduledSnapshot.docs.isNotEmpty;
}

}