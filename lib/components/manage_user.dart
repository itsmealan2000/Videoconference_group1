import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:fluttertoast/fluttertoast.dart';

class ManageUserDataPage extends StatefulWidget {
  const ManageUserDataPage({super.key});

  @override
  State<ManageUserDataPage> createState() => _ManageUserDataPageState();
}

class _ManageUserDataPageState extends State<ManageUserDataPage> {
  User? user;
  String fullName = '';
  String email = '';
  String phoneNumber = '';

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _fetchUserData(user!.uid);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          fullName = snapshot['fullName'] ?? 'No name available';
          email = snapshot['email'] ?? 'No email available';
          phoneNumber = snapshot['mobileNumber'] ?? 'No phone number available';
          _fullNameController.text = fullName; 
          _emailController.text = email;
          _phoneNumberController.text = phoneNumber;
          _isEditing = true; 
        });
      } else {
        Fluttertoast.showToast(msg: 'User Details Not Filled.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'mobileNumber': _phoneNumberController.text,
        });

        Fluttertoast.showToast(msg: 'User data saved successfully.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 20),
            if (_isEditing)
              ElevatedButton(
                onPressed: () {
                  _saveUserData();
                },
                child: const Text('Save Changes'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true; 
                  });
                },
                child: const Text('Add Details'),
              ),
          ],
        ),
      ),
    );
  }
}
