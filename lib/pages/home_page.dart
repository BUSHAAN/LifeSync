// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/all_events_page.dart';
import 'package:flutter_todo_app/pages/all_tasks_page.dart';
import 'package:flutter_todo_app/pages/prediction.dart';
import 'package:flutter_todo_app/pages/scheduling_section.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _hasNewPrediction = false;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }
  @override
  void initState() {
    print("Checking for new predictions");
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            "LifeSync",
            style: (TextStyle(
              color: Colors.white,
            )),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.insights), // Use an appropriate icon
                onPressed: () {
                  // Navigate to the prediction page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PredictionPage()),
                  );
                  
                  // Reset the new prediction indicator once the user views the page
                  setState(() {
                    _hasNewPrediction = false;
                  });
                },
              ),
              if (_hasNewPrediction)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
          ],
          backgroundColor: Colors.blue.shade600,
        ),
        drawer: Drawer(
          backgroundColor: Colors.grey.shade100,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                ),
                child: Column(
                  children: [
                    Text(
                      'LifeSync',
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      "Logged in as ${user!.email!}",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('All Tasks'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllTasksPage()),
                  );
                },
              ),
              ListTile(
                title: const Text('All Events'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllEventsPage()),
                  );
                },
              ),
              ListTile(
                title: const Text('Prediction Page'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PredictionPage()),
                  );
                },
              ),
              ListTile(
                title: const Text('Sign Out'),
                onTap: () {
                  signUserOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: SchedulingSection(),
        ));
  }
}
