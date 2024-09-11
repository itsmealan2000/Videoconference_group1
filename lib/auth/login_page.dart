// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/pages/home_page.dart';
import 'package:videoconference/auth/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email == "" || password == "") {
      print("Please fill all the fields!!!");
    } else {
      signIn(email, password);
    }
  }

  void signIn(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (e) {
      print(e.message.toString());
    }

    if (credential!=null) {
      //String uid=credential.user!.uid;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
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
                  style: TextStyle(color: Colors.grey.shade50),
                  obscureText: false,
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
                  style: TextStyle(color: Colors.grey.shade50),
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      label: Text("Password"),
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
                    'SIGN IN',
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
                    "Don't have account? ",
                    style: TextStyle(color: Colors.grey.shade100, fontSize: 16),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage(),));
                  },
                  child: Text("Sign Up ",
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
