import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for user details
import 'package:videoconference/components/bottomnavbar.dart';
import 'package:videoconference/pages/contacts_page.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:videoconference/auth/meeting_service.dart'; // Meeting service
import 'package:flutter/services.dart'; // For Clipboard copy
import 'package:share/share.dart'; // Share package

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? activeMeetingCode; // Variable to store active meeting code

  // Function to fetch current user's name from Firestore
  Future<String?> getCurrentUserName() async {
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
      return null; // Return null if no user is signed in
    }
  }

  // Function to start a meeting
  Future<void> _startMeeting() async {
    try {
      // Get the current user's name
      String? currentUserName = await getCurrentUserName();
      if (currentUserName == null) {
        throw Exception('User not signed in or name not found');
      }
      
      // Get current user's email instead of UID
      String email = FirebaseAuth.instance.currentUser!.email ?? ''; // Get current user's email

      // Generate a random room code or use a timestamp
      String roomCode = DateTime.now().millisecondsSinceEpoch.toString();

      // Create an instance of MeetingService
      MeetingService meetingService = MeetingService();

      // Start the Jitsi meeting
      await meetingService.createMeeting(
        roomCode: roomCode,
        username: currentUserName,
        email: email,
      );

      // Safely update the UI after async call
      if (!mounted) return;
      setState(() {
        activeMeetingCode = roomCode;
      });
    } catch (e) {
      // Error handling
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to copy meeting code to clipboard
  void _copyMeetingCode() {
    if (activeMeetingCode != null) {
      Clipboard.setData(ClipboardData(text: activeMeetingCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting code copied to clipboard!')),
      );
    }
  }

  Future<void> _handleContactsNavigation() async {
    try {
      // Fetch the current user's name and contacts asynchronously
      String? currentUserName = await getCurrentUserName();
      List<Contact> contacts = (await ContactsService.getContacts()).toList();

      // Navigate to ContactsPage only if the widget is still mounted
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactsPage(
              currentUser: currentUserName ?? 'Unknown User', // Handle null case
              contacts: contacts,
              onContactSelected: (contact) {
                // Handle contact selection
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Handle errors (e.g., user not signed in)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching contacts: $e')),
        );
      }
    }
  }

  // Function to share the meeting code
  void _shareMeetingCode() {
    if (activeMeetingCode != null) {
      Share.share('Join my meeting with code: https://jitsi.rptu.de/$activeMeetingCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _startMeeting, // No need to pass context here
                child: const Text("Start Meeting", style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to join meeting here
                },
                child: const Text("Join Meeting", style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 20),
              if (activeMeetingCode != null)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Active Meeting Code:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                activeMeetingCode!,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyMeetingCode,
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: _shareMeetingCode,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleContactsNavigation,
        child: const Icon(Icons.contacts),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
