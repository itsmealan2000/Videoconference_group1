// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/auth/complete_profile.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPwController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPwController.text.trim();

    if (email == "" || password == "" || confirmPassword == "") {
      if (kDebugMode) {
        print("Please fill all the fields!!!");
      }
    } else {
      if (password == confirmPassword) {
        signUp(email, password);
      }
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.message.toString());
      }
    }

    if (credential != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteProfile(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color.fromARGB(255, 169, 37, 240),
              Color.fromARGB(255, 51, 215, 227)
            ])),
          ),
          Container(
            margin: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Video Chat ",
                      style:
                          TextStyle(fontSize: 30, color: Colors.grey.shade50),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 25,
                      color: Colors.grey.shade50,
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Text("Welcome to Video Chat App",
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade200))
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  obscureText: false,
                  style: TextStyle(color: Colors.grey.shade50),
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      label: Text("Email"),
                      labelStyle: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  obscureText: true,
                  style: TextStyle(color: Colors.grey.shade50),
                  controller: passwordController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      label: Text("Password"),
                      labelStyle: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  style: TextStyle(color: Colors.grey.shade50),
                  controller: confirmPwController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      label: Text("Confirm Password"),
                      labelStyle: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Material(
                elevation: 5,
                shadowColor: Colors.black,
                borderRadius: BorderRadius.circular(15),
                child: CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
                  borderRadius: BorderRadius.circular(15),
                  onPressed: checkValues,
                  color: Colors.yellow.shade400,
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 22),
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.all(15),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Text(
                    "Already have account? ",
                    style: TextStyle(color: Colors.grey.shade100, fontSize: 16),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Sign In ",
                      style: TextStyle(
                          color: Colors.grey.shade100,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
