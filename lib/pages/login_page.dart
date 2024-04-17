// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/widgets/my_button.dart';
import 'package:flutter_todo_app/widgets/my_square_tile.dart';
import 'package:flutter_todo_app/widgets/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      showErrorMessage(error.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.red,
              title: Text(
                message,
                style: TextStyle(color: Colors.white),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                SizedBox(height: 30),
                Icon(
                  Icons.person,
                  size: 100,
                ),
                //welcome back
                SizedBox(height: 30),

                Text(
                  "Welcome Back! ",
                  style: TextStyle(color: Colors.grey[700], fontSize: 28),
                ),

                //username textfield
                SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Enter email',
                  obscureText: false,
                ),
                //password textfield
                SizedBox(height: 25),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Enter password',
                  obscureText: true,
                ),
                SizedBox(height: 10),
                //forget password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("forgot password?",
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                //sign in button
                MyButton(
                  text: 'Sign-in',
                  onTap: signUserIn,
                ),
                SizedBox(height: 25),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                // google and apple logos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MySquareTile(
                      imagePath: 'assets/images/google.png',
                      height: 40,
                    ),
                    SizedBox(width: 10),
                    MySquareTile(
                      imagePath: 'assets/images/apple.png',
                      height: 40,
                    )
                  ],
                ),
                SizedBox(height: 25),
                // dont have an account? sign up now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account yet?",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Register now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
