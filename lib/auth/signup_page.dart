// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/pages/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPwController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      if (kDebugMode) {
        print("Please fill all the fields!!!");
      }
    } else if (password == confirmPassword) {
      signUp(email, password);
    } else {
      if (kDebugMode) {
        print("Passwords do not match!");
      }
    }
  }

  Future<void> saveUserToFirestore(String uid, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await saveUserToFirestore(credential.user!.uid, email);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteProfile(),
          ));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
      // Show an error dialog to the user
      _showErrorDialog(e.message);
    }
  }

  void _showErrorDialog(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message ?? "An error occurred. Please try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
                color: Colors.black
              ),
            ),
            SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Video Chat",
                            style: TextStyle(
                                fontSize: 30, color: Colors.grey.shade50),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 25,
                            color: Colors.grey.shade50,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text("Welcome to Video Chat App",
                          style: TextStyle(
                              fontSize: 20, color: Colors.grey.shade200))
                    ],
                  ),
                ),
                Container(
                width: 300,
                height: 300,
                  decoration: const BoxDecoration(
                  image : DecorationImage(
                    image: AssetImage('assets/bg/1.png'),
                    fit: BoxFit.contain,
                    ),
                ),
                ),
                // Input Fields
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(emailController, "Email", false),
                      const SizedBox(height: 15),
                      _buildTextField(passwordController, "Password", true),
                      const SizedBox(height: 15),
                      _buildTextField(
                          confirmPwController, "Confirm Password", true),
                      const SizedBox(height: 20),
                      _buildSignUpButton(),
                    ],
                  ),
                ),
                Container(
                width: 150,
                height: 150,
                  decoration: const BoxDecoration(
                  image : DecorationImage(
                    image: AssetImage('assets/bg/2.png'),
                    fit: BoxFit.contain,
                    ),
                ),
                ),
                // Sign In Link
                Container(
                  margin: const EdgeInsets.all(15),
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                            color: Colors.grey.shade100, fontSize: 16),
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
                ),
              ],
            ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isObscure) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1, color: const Color.fromARGB(255, 255, 255, 255)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        obscureText: isObscure,
        style: TextStyle(color: Colors.grey.shade50),
        controller: controller,
        decoration: InputDecoration(
          border:OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          label: Text(label),
          labelStyle: const TextStyle(
            fontSize: 25, 
            color: Colors.white
            ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Material(
      elevation: 5,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(15),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
        borderRadius: BorderRadius.circular(15),
        onPressed: checkValues,
        color: Colors.yellow.shade400,
        child: Text(
          'SIGN UP',
          style: TextStyle(color: Colors.grey.shade900, fontSize: 22),
        ),
      ),
    );
  }
}

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  void checkValues() async {
    String fullName = fullnameController.text.trim();
    String mobileNumber = numberController.text.trim();

    if (fullName.isNotEmpty && mobileNumber.isNotEmpty) {
      await saveProfileToFirestore(fullName, mobileNumber);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else {
      if (kDebugMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields!")),
        );
      }
    }
  }

  Future<void> saveProfileToFirestore(
      String fullName, String mobileNumber) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'fullName': fullName,
        'mobileNumber': mobileNumber,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 169, 37, 240),
                    Color.fromARGB(255, 51, 215, 227)
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: () {},
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.amber.shade300,
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.grey.shade50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(fullnameController, "Full Name"),
                      const SizedBox(height: 5),
                      _buildTextField(numberController, "Mobile Number"),
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: TextStyle(color: Colors.grey.shade50),
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          label: Text(label),
          labelStyle: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      elevation: 5,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(15),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
        borderRadius: BorderRadius.circular(15),
        onPressed: checkValues,
        color: Colors.yellow.shade400,
        child: Text(
          'Submit',
          style: TextStyle(color: Colors.grey.shade900, fontSize: 22),
        ),
      ),
    );
  }
}
