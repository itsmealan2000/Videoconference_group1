import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/components/bottomnavbar.dart'; 
import 'package:contacts_service/contacts_service.dart'; 
import 'package:permission_handler/permission_handler.dart'; 
import 'package:videoconference/pages/chat_page.dart'; 
import 'package:videoconference/pages/contacts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  List<Map<String, String>> recentChats = []; 

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    recentChats = [
      {"name": "John Doe", "phone": "+1234567890"},
      {"name": "Jane Smith", "phone": "+9876543210"},
      {"name": "Alice Brown", "phone": "+1112223334"},
    ];
  }

  String getUserNameFromEmail(String email) {
    return email.split('@').first;
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
          children: [
            if (user != null) ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text('Welcome, ${getUserNameFromEmail(user!.email!.toUpperCase())}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                )
              ),
            ],
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recent Chats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentChats.length,
                itemBuilder: (context, index) {
                  final chat = recentChats[index];
                  return ListTile(
                    leading: const Icon(Icons.chat),
                    title: Text(chat['name'] ?? 'Unknown'),
                    subtitle: Text(chat['phone'] ?? 'No phone'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            contactName: chat['name'] ?? 'Unknown',
                            phoneNumber: chat['phone'] ?? 'No Number',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
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
