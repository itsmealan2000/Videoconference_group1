// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:videoconference/pages/home_page.dart';
class CompleteProfile extends StatefulWidget {

  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  File? _selectedImage;


  Future<void> _pickImage()async {
    final ImagePicker _picker = ImagePicker();
    final XFile? _imageUrl = await _picker.pickImage(source: ImageSource.gallery);
    if (_imageUrl!=null) {
      setState(() {
        _selectedImage = File(_imageUrl.path);
      });
    }
  }

  void checkValues() async {
    String fullName = fullnameController.text.trim();
    String mobileNumber = numberController.text.trim();
    File? image=_selectedImage;

    if (fullName.isNotEmpty && mobileNumber.isNotEmpty) {
      await saveProfileToFirestore(fullName, mobileNumber,image!);
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
      String fullName, String mobileNumber,File image) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'profilepic': image.toString()
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
                  onPressed: _pickImage,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color.fromARGB(255, 67, 138, 196),
                    backgroundImage: (_selectedImage!=null)?FileImage(_selectedImage!):null,
                    child: (_selectedImage == null)?Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.grey.shade50,
                    ):null,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(fullnameController, "Full Name"),
                      const SizedBox(height: 10),
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
        border: Border.all(width: 2, color: const Color.fromARGB(255, 245, 242, 239)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: TextStyle(color: Colors.grey.shade50),
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          label: Text(label),
          labelStyle: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      elevation: 5,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(15),
      // child: CupertinoButton(
      //   padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
      //   borderRadius: BorderRadius.circular(15),
      //   onPressed: checkValues,
      //   color: Colors.yellow.shade400,
      //   child: Text(
      //     'Submit',
      //     style: TextStyle(color: Colors.grey.shade900, fontSize: 22),
      //   ),
      // ),
           child: GestureDetector(
        onTap: checkValues,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/15,
          
          //padding: const EdgeInsets.symmetric(horizontal: 140,vertical: 10),
          decoration: BoxDecoration(
            color: Colors.yellow.shade400,
            borderRadius: BorderRadius.circular(15)
          ),
          child: Center(child: Text('SUBMIT',style: TextStyle(color: Colors.grey.shade900,fontSize: 22,fontWeight: FontWeight.w500,),)),
        ),
      ),
    );
  }
}