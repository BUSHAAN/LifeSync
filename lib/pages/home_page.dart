// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/add_task.dart';
import 'package:flutter_todo_app/pages/all_tasks.dart';
import 'package:flutter_todo_app/pages/login_or_register_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: signUserOut,
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ))
          ],
          centerTitle: true,
          title: Text(
            "LifeSync",
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
              MaterialPageRoute(builder: (context) => AddTasksPage()),
            );
          },
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllTasks()),
                    );
                  },
                  child: Text("all tasks")),
              SizedBox(
                height: 50,
              ),
              Text("Logged in as " + user!.email!)
            ],
          ),
        ));
  }
}
