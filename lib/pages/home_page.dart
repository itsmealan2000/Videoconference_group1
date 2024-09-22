import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/components/bottomnavbar.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videoconference/pages/chat_page.dart';
import 'package:videoconference/components/recent_chats.dart';
import 'package:videoconference/pages/contacts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  String? fullName;
  List<Map<String, String>> recentChats = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchUserFullName();
    fetchRecentChatsFromFirebase();
  }

  Future<void> fetchUserFullName() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (userDoc.exists && userDoc['fullName'] != null) {
          setState(() {
            fullName = userDoc['fullName'];
          });
        }
      } catch (e) {
        // Handle error if necessary
      }
    }
  }

  Future<void> fetchRecentChatsFromFirebase() async {
    // Simulating Firebase data retrieval (Replace with actual Firebase query)
    List<Map<String, String>> fetchedChats = [
      {"name": "John Doe", "phone": "+1234567890"},
      {"name": "Jane Smith", "phone": "+9876543210"},
      {"name": "Alice Brown", "phone": "+1112223334"},
    ];

    setState(() {
      recentChats = fetchedChats;
    });
  }

  Future<void> _handleContactsAccess() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        List<Contact> contacts = await ContactsService.getContacts();
        if (!mounted) return;  // Check if widget is still mounted
        _navigateToContactsPage(contacts);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching contacts')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied')),
      );
    }
  }

  void _navigateToContactsPage(List<Contact> contacts) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsPage(
          contacts: contacts,
          onContactSelected: (contact) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  contactName: contact.displayName ?? 'No Name',
                  phoneNumber: contact.phones?.isNotEmpty == true
                      ? contact.phones!.first.value ?? 'No Number'
                      : 'No Number',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (user != null && fullName != null) ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, $fullName',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recent Chats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            RecentChats(recentChats: recentChats),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleContactsAccess,
        child: const Icon(Icons.contacts),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
