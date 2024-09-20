import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/components/bottomnavbar.dart'; 
import 'package:videoconference/auth/login_page.dart'; // Import your login page
import 'package:contacts_service/contacts_service.dart'; // Import for contacts
import 'package:permission_handler/permission_handler.dart'; // Import for permissions
import 'package:videoconference/pages/chat_page.dart'; // Import your ChatPage
import 'package:videoconference/pages/contacts_page.dart'; // Import your ContactsPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    // Load the current user once the state is initialized
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // Redirect to login page
      (route) => false, // Remove all previous routes
    );
  }

  Future<void> _handleContactsAccess() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      List<Contact> contacts = await ContactsService.getContacts();
      if (!mounted) return;
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
                    phoneNumber: contact.phones?.first.value ?? 'No Number',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied')),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Welcome to the Video Conference App"),
            ),
            if (user != null) ...[
              const SizedBox(height: 20),
              Text("Logged in as: ${user!.email}"),
              const SizedBox(height: 20),
              CupertinoButton(
                color: Colors.blue,
                onPressed: _logout,
                child: const Text("Logout"),
              ),
            ],
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
