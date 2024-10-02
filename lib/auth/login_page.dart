import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:videoconference/pages/home_page.dart';
import 'package:videoconference/auth/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Color backgroundColor = Colors.black;
  final Color textColor = Colors.white;
  final TextStyle labelTextStyle =
      const TextStyle(fontSize: 20, color: Colors.white);
  final BoxDecoration textFieldDecoration = BoxDecoration(
    border:
        Border.all(width: 1, color: const Color.fromARGB(255, 255, 255, 255)),
    borderRadius: BorderRadius.circular(15),
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all the fields!!!");
    } else if (!_isValidEmail(email)) {
      _showSnackBar("Invalid email format. Please try again.");
    } else {
      signIn(email, password);
    }
  }

  bool _isValidEmail(String email) {
    // Simple regex for validating email
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackBar("Incorrect password. Please try again.");
      } else {
        _showSnackBar("Wrong Data");
      }
      if (kDebugMode) {
        print(e.message.toString());
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: textFieldDecoration,
      child: TextField(
        style: TextStyle(color: textColor),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black),
          ),
          labelText: labelText,
          labelStyle: labelTextStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background color
            Container(
              color: backgroundColor,
            ),
            // Main content
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // Space at the top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Video Chat",
                        style: TextStyle(fontSize: 30, color: textColor),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 25, color: textColor),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Welcome to Video Chat App",
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade200),
                  ),
                  // Logo image
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Image.asset('assets/bg/3.png', fit: BoxFit.contain),
                  ),
                  // Form fields and sign in button
                  buildTextField(
                      controller: emailController, labelText: "Email"),
                  buildTextField(
                      controller: passwordController,
                      labelText: "Password",
                      obscureText: true),
                  const SizedBox(height: 20),
                  Material(
                    elevation: 5,
                    shadowColor: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    // child: CupertinoButton(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 140, vertical: 20),
                    //   borderRadius: BorderRadius.circular(15),
                    //   onPressed: checkValues,
                    //   color: Colors.yellow.shade400,
                    //   child: Text(
                    //     'SIGN IN',
                    //     style: TextStyle(
                    //         color: Colors.grey.shade900, fontSize: 22),
                    //   ),
                    // ),
                    child: GestureDetector(
                      onTap: checkValues,
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.115,
                        height: MediaQuery.of(context).size.height / 14,

                        //padding: const EdgeInsets.symmetric(horizontal: 140,vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.yellow.shade400,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                            child: Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  // Sign up section at the bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                            color: Colors.grey.shade100, fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.grey.shade100,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
