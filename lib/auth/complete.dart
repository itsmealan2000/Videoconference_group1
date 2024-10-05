import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage for uploading images
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:videoconference/pages/home_page.dart';

class Complete extends StatefulWidget {
  const Complete({super.key});

  @override
  State<Complete> createState() => _CompleteState();
}

class _CompleteState extends State<Complete> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  File? _selectedImage; // For storing the selected image
  bool _isLoading = false; // To indicate loading state

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> uploadImageToFirebase(File image) async {
    try {
      // Get a reference to the storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${FirebaseAuth.instance.currentUser!.uid}/profile.jpg');

      // Upload the image
      await storageRef.putFile(image);

      // Get the download URL of the uploaded image
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void checkValues() async {
    String fullName = fullnameController.text.trim();
    String mobileNumber = numberController.text.trim();

    if (fullName.isNotEmpty && mobileNumber.isNotEmpty && _selectedImage != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      String? imageUrl = await uploadImageToFirebase(_selectedImage!);
      if (imageUrl != null) {
        await saveProfileToFirestore(fullName, mobileNumber, imageUrl);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed!")),
        );
      }
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select an image!")),
      );
    }
  }

  Future<void> saveProfileToFirestore(
      String fullName, String mobileNumber, String imageUrl) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'profilepic': imageUrl, // Storing the image URL in Firestore
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
                  onPressed: pickImage, // Image picker button
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color.fromARGB(255, 67, 138, 196),
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey.shade50,
                          )
                        : null,
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
                      _isLoading // Show loading spinner when uploading
                          ? const CircularProgressIndicator()
                          : _buildSubmitButton(),
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
      child: GestureDetector(
        onTap: checkValues, // On tap, check and upload the profile data
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 15,
          decoration: BoxDecoration(
            color: Colors.yellow.shade400,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              'SUBMIT',
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
