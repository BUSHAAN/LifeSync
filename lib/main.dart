// ignore_for_file: prefer_const_constructors

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo_app/firebase_options.dart';
import 'package:flutter_todo_app/pages/auth_page.dart';
import 'package:flutter_todo_app/services/task_prediction_services.dart';

const taskName = 'taskPrediction';
void callbackDispatcher() {
  MLServices mlServices = MLServices();
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'life_sync',
        channelName: 'Life Sync',
        channelDescription: 'Notification channel for Life Sync',
      )
    ],
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      home: AuthPage(),
    );
  }
}
