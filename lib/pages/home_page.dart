import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for user details
import 'package:videoconference/components/bottomnavbar.dart';
import 'package:videoconference/pages/contacts_page.dart';
import 'package:contacts_service/contacts_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Function to fetch current user's name from Firestore
  Future<String> getCurrentUserName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      try {
        // Fetch user's details from Firestore using the UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Assuming user's name is stored in the 'fullName' field
          return userDoc['fullName'];
        } else {
          throw Exception('User details not found in Firestore');
        }
      } catch (e) {
        throw Exception('Error fetching user details: $e');
      }
    } else {
      throw Exception('No user is signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Get the current user's name
            String currentUserName = await getCurrentUserName();

            // Fetch contacts from device
            List<Contact> contacts = await ContactsService.getContacts();

            // Navigate to ContactsPage with the fetched currentUserName
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactsPage(
                  currentUser: currentUserName, // Pass the current user name
                  contacts: contacts,
                  onContactSelected: (contact) {
                    // Handle contact selection
                  },
                ),
              ),
            );
          } catch (e) {
            // Handle errors (e.g., user not signed in)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        child: const Icon(Icons.contacts),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
