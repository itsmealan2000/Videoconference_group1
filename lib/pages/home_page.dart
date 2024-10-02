import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:videoconference/components/bottomnavbar.dart';
import 'package:videoconference/pages/contacts_page.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:videoconference/auth/meeting_service.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:videoconference/components/join_meeting.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? activeMeetingCode;

  // Fetch current user's name from Firestore
  Future<String?> getCurrentUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userDoc.exists ? userDoc['fullName'] : null;
      } catch (e) {
        _showSnackBar('Error fetching user details: $e');
      }
    }
    return null;
  }

  // Start a meeting
  Future<void> _startMeeting() async {
    try {
      String? currentUserName = await getCurrentUserName();
      if (currentUserName == null) {
        throw Exception('User not signed in or name not found');
      }
      String email = FirebaseAuth.instance.currentUser!.email ?? '';
      String roomCode = DateTime.now().millisecondsSinceEpoch.toString();
      MeetingService meetingService = MeetingService();

      await meetingService.createMeeting(
        roomCode: roomCode,
        username: currentUserName,
        email: email,
      );

      if (!mounted) return;
      setState(() {
        activeMeetingCode = roomCode;
      });
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  // Copy meeting code to clipboard
  void _copyMeetingCode() {
    if (activeMeetingCode != null) {
      Clipboard.setData(ClipboardData(text: activeMeetingCode!));
      _showSnackBar('Meeting code copied to clipboard!');
    }
  }

  // Handle navigation to contacts
  Future<void> _handleContactsNavigation() async {
    try {
      String? currentUserName = await getCurrentUserName();
      List<Contact> contacts = (await ContactsService.getContacts()).toList();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactsPage(
              currentUser: currentUserName ?? 'Unknown User',
              contacts: contacts,
              onContactSelected: (contact) {
                
              },
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Error fetching contacts: $e');
    }
  }

  // Share meeting code
  void _shareMeetingCode() {
    if (activeMeetingCode != null) {
      Share.share(
          'Join my meeting with code: https://jitsi.rptu.de/$activeMeetingCode');
    }
  }

  // Show SnackBar
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Navigate to JoinMeeting page
  void _navigateToJoinMeeting() async {
    String? currentUserName = await getCurrentUserName();
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (!mounted) return;
    if (currentUserName != null && currentUserEmail != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinMeeting(
            username: currentUserName,
            email: currentUserEmail,
          ),
        ),
      );
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
                onPressed: _startMeeting,
                child:
                    const Text("Start Meeting", style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToJoinMeeting,
                child:
                    const Text("Join Meeting", style: TextStyle(fontSize: 20)),
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
                          'Recent Meeting Code:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
