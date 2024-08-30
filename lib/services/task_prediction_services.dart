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
        .where('isEvent', isEqualTo: false)
        .where('startDateTime', isLessThanOrEqualTo: now)
        .where('endDateTime', isGreaterThan: now)
        .limit(1)
        .get();

    // If there's a task scheduled right now, return true
    if (currentTaskQuery.docs.isNotEmpty) {
      return true;
    }

    // Query to check if there's a free slot within the next 4 hours
    var freeSlotQuery = await FirebaseFirestore.instance
        .collection('DailyItems')
        .where('userId', isEqualTo: userId)
        .where('isEvent', isEqualTo: false)
        .where('startDateTime', isLessThanOrEqualTo: fourHoursFromNow)
        .where('endDateTime', isGreaterThan: now)
        .get();

    // If there's a free slot in the next 4 hours, return true
    return freeSlotQuery.docs.isEmpty;
  }

  Future<List<Map<String, dynamic>>> fetchLastTasks(
      String userId, int numberOfTasks) async {
    // Get current time
    DateTime now = DateTime.now();
    DateTime eightHoursAgo = now.subtract(const Duration(hours: 8));

    // Query to fetch the last few tasks within the past 8 hours
    var tasksQuery = await FirebaseFirestore.instance
        .collection('DailyItems')
        .where('userId', isEqualTo: userId)
        .where('isEvent', isEqualTo: false)
        .where('endDateTime', isGreaterThan: eightHoursAgo)
        .orderBy('endDateTime', descending: true)
        .limit(numberOfTasks)
        .get();

    // Convert the query snapshot to a list of task maps
    List<Map<String, dynamic>> tasks =
        tasksQuery.docs.map((doc) => doc.data()).toList();

    return tasks;
  }

  String getTimeOfDay(int hour) {
    if (hour >= 6 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 16) return 'Afternoon';
    if (hour >= 16 && hour < 21) return 'Evening';
    if (hour >= 21 || hour < 6) return 'Late-Night';
    return 'After-Midnight';
  }

  Map<String, dynamic> formatTaskData(List<Map<String, dynamic>> tasks) {
    List<Map<String, dynamic>> formattedTasks = tasks.map((task) {
      // Extract hour from startDateTime
      DateTime startDateTime = (task['startDateTime'] as Timestamp).toDate();
      int hour = startDateTime.hour;

      // Determine time of day
      String timeOfDay = getTimeOfDay(hour);

      return {
        'task_name': task['itemName'],
        'duration': task['duration'],
        'time_of_day': timeOfDay
      };
    }).toList();

    return {'tasks': formattedTasks};
  }

  Future<String?> sendTaskDataToApi(List<Map<String, dynamic>> tasks) async {
    // Format the task data
    Map<String, dynamic> formattedData = formatTaskData(tasks);
    print(formattedData);
    // Convert the formatted data to JSON
    String jsonBody = jsonEncode(formattedData);

    // Define the API endpoint
    final String apiUrl = 'http://10.0.2.2:5000/predict';

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Parse the JSON response
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        // Extract the predicted task name
        String predictedTaskName =
            responseData['predicted_task_name'] ?? 'No task predicted';

        // Print the response
        print('API call successful');
        print('Predicted task name: $predictedTaskName');

        return predictedTaskName;
      } else {
        // Error response
        print('API call failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        return null;
      }
    } catch (e) {
      // Handle any exceptions
      print('Error making API call: $e');

      return null;
    }
  }

  Future<String?> checkForFreeSlotAndPredict() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final isFree = await isCurrentTaskOrFreeSlot(userId);
    if (isFree) {
      print('You have a free slot in the next 4 hours');
      final tasks = await fetchLastTasks(userId, 2);
      final prediction = await sendTaskDataToApi(tasks);
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // if (prediction != null){
      //   await prefs.setString('latest_prediction', prediction);
      // }
      // NotificationService notificationService = NotificationService();
      // notificationService.showNotification(
      //     "New Task Prediction Available", "Tap to see the suggestion.");

      return prediction; // Return the prediction
    } else {
      print('You have a task scheduled right now');
      return null; // Return null if no prediction is made
    }
  }
}
