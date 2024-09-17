import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/auth/auth_page.dart';
import 'package:videoconference/firebase_options.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'contacts_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Conference App',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _headerTitle = 'Auth Page'; // Initial header title

  // Function to update header title
  void _updateHeaderTitle(String newTitle) {
    setState(() {
      _headerTitle = newTitle;
    });
  }

  // Fetch contacts and navigate to the ContactsPage
  Future<void> _fetchContactsAndNavigate() async {
    // Request permission to access contacts
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      // Fetch contacts
      List<Contact> contacts = await ContactsService.getContacts();
      // Navigate to the ContactsPage
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactsPage(contacts: contacts),
          ),
        );
      }
    } else {
      // Handle permission denied
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access contacts denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_headerTitle), // Dynamic header title
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const AuthPage(), // Replace with your page content
          Positioned(
            bottom: 20, // Position above the footer
            right: 20, // Right corner
            child: FloatingActionButton(
              onPressed: () async {
                await _fetchContactsAndNavigate(); // Fetch contacts and navigate to ContactsPage
                _updateHeaderTitle('Contacts');
              },
              tooltip: 'Contact',
              child: const Icon(Icons.contacts),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  _updateHeaderTitle('Chat');
                  // Add chat functionality here
                },
                tooltip: 'Chat',
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  _updateHeaderTitle('Voice Call');
                  // Add voice call functionality here
                },
                tooltip: 'Voice Call',
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  _updateHeaderTitle('Video Call');
                  // Add video call functionality here
                },
                tooltip: 'Video Call',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _updateHeaderTitle('Settings');
                  // Add settings functionality here
                },
                tooltip: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
