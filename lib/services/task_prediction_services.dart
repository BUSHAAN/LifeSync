import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_todo_app/model/schedules.dart';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http;

class MLServices {
  final CollectionReference dailyItems =
      FirebaseFirestore.instance.collection("DailyItems");

  Future<bool> isCurrentTaskOrFreeSlot(String userId) async {
    // Get current time
    DateTime now = DateTime.now();
    DateTime fourHoursFromNow = now.add(Duration(hours: 4));

    // Query to check if there's any task scheduled right now
    var currentTaskQuery = await FirebaseFirestore.instance
        .collection('DailyItems')
        .where('userId', isEqualTo: userId)
        .where('startDateTime', isLessThanOrEqualTo: now)
        .where('endDateTime', isGreaterThan: now)
        .limit(1)
        .get();

    // If there's a task scheduled right now, return true
    if (currentTaskQuery.docs.isEmpty) {
      return true;
    }

    // Query to check if there's a free slot within the next 4 hours
    var freeSlotQuery = await FirebaseFirestore.instance
        .collection('DailyItems')
        .where('userId', isEqualTo: userId)
        .where('startDateTime', isLessThanOrEqualTo: fourHoursFromNow)
        .where('endDateTime', isGreaterThan: now)
        .get();

    // If there's a free slot in the next 4 hours, return true
    if (freeSlotQuery.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLastTasks(
      String userId, int numberOfTasks) async {
    // Get current time
    DateTime now = DateTime.now();

    // Query to fetch the last few tasks within the past 8 hours
    var tasksQuery = await FirebaseFirestore.instance
        .collection('DailyItems')
        .where('userId', isEqualTo: userId)
        .where('startDateTime', isLessThan: now)
        .orderBy('endDateTime', descending: true)
        .limit(numberOfTasks)
        .get();

    // Convert the query snapshot to a list of task maps
    List<Map<String, dynamic>> last_dailyItems =
        tasksQuery.docs.map((doc) => doc.data()).toList();

    return last_dailyItems;
  }

  String getDayOfWeek(DateTime dateTime) {
    // List of days of the week, starting with Monday
    const List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    // Get the weekday as an integer (1 for Monday, 7 for Sunday)
    int dayIndex = dateTime.weekday;

    // Return the corresponding day name
    return daysOfWeek[dayIndex - 1];
  }

  String convertDateTimeToCustomFormat(DateTime dateTime) {
    // Extract the hour and minute components
    int hour = dateTime.hour;
    int minute = dateTime.minute;

    // Return the time in the custom format as a single integer
    return (hour * 100 + minute).toString();
  }

  Map<String, dynamic> formatTaskData(List<Map<String, dynamic>> dailyItems) {
    List<Map<String, dynamic>> formattedTasks = dailyItems.map((dailyItem) {
      // Extract hour from startDateTime

      DateTime startDateTime =
          (dailyItem['startDateTime'] as Timestamp).toDate();
      String dayOfWeek = getDayOfWeek(startDateTime);
      String startDateTimeFormatted =
          convertDateTimeToCustomFormat(startDateTime);
      String endDateTimeFormatted = convertDateTimeToCustomFormat(
          (dailyItem['endDateTime'] as Timestamp).toDate());

      return {
        'task_name': dailyItem['itemName'],
        'start_time': startDateTimeFormatted,
        'end_time': endDateTimeFormatted,
        'duration': dailyItem['duration'],
        'weekday': dayOfWeek,
      };
    }).toList();
    return {'tasks': formattedTasks};
  }

Future<Map<String, dynamic>> sendTaskDataToPredict(
    List<Map<String, dynamic>> tasks) async {
  // Format the task data
  Map<String, dynamic> formattedData = formatTaskData(tasks);
  // Convert the formatted data to JSON
  String jsonBody = jsonEncode(formattedData);

  // Define the API endpoint
  final String apiUrl = 'http://10.0.2.2:5000/predict';

  // Make the POST request
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonBody,
  );

  if (response.statusCode == 200) {
    // Parse the JSON response
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    // Extract predictions and filter them
    List<Map<String, dynamic>> predictions = List<Map<String, dynamic>>.from(
        responseData['predictions'] ?? []);

    List<Map<String, dynamic>> filteredPredictions =
        filterPredictionsByTime(predictions);

    return {
      'predictions': filteredPredictions,
      'error': responseData['error'] ?? ""
    };
  } else {
    print('API call failed with status code: ${response.statusCode}');
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return responseData;
  }
}


  List<Map<String, dynamic>> filterPredictionsByTime(
      List<Map<String, dynamic>> predictions) {

    DateTime now = DateTime.now();

    final Map<String, List<int>> taskTimeRanges = {
      'breakfast': [6, 10],
      'lunch': [11, 14],
      'dinner': [19, 23],
      'sleep': [20, 24],
    };

    int currentHour = now.hour;

    List<Map<String, dynamic>> filteredPredictions =
        predictions.where((prediction) {
      String taskName = prediction['prediction'].toString().toLowerCase();

      if (taskTimeRanges.containsKey(taskName)) {
        List<int> timeRange = taskTimeRanges[taskName]!;
        if (currentHour >= timeRange[0] && currentHour < timeRange[1]) {
          return true;
        } else if (timeRange[1] == 24 && currentHour < timeRange[1]) {
          return true;
        } else {
          return false;
        }
      }
      return true;
    }).toList();

    return filteredPredictions;
  }

  Future<Map<String, dynamic>> checkForFreeSlotAndPredict() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    print('You have a free slot in the next 4 hours');
    final tasks = await fetchLastTasks(userId, 10);
    final predictions = await sendTaskDataToPredict(tasks);


    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'life_sync',
        title: 'New Prediction',
        body: 'You have a new prediction. Click to view',
      ),
    );
    return predictions;
  }
}
