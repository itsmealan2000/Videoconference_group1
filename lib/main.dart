import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videoconference/ChatPage.dart';
import 'firebase_options.dart';
import 'contacts_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Contact> _recentChats = []; // List to keep track of recent chats

  void _addRecentChat(Contact contact) {
    setState(() {
      if (!_recentChats.contains(contact)) {
        _recentChats.add(contact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Conference App',
      debugShowCheckedModeBanner: false,
      home: HomePage(
        recentChats: _recentChats,
        onChatStarted: _addRecentChat,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Contact> recentChats;
  final Function(Contact) onChatStarted;

  const HomePage(
      {super.key, required this.recentChats, required this.onChatStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
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
                final contact = recentChats[index];
                final displayName = contact.displayName ?? 'No Name';
                final phoneNumber = contact.phones?.isNotEmpty == true
                    ? contact.phones!.first.value ?? 'No Number'
                    : 'No Number';
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage:
                        contact.avatar != null && contact.avatar!.isNotEmpty
                            ? MemoryImage(contact.avatar!)
                            : null,
                    child: contact.avatar == null || contact.avatar!.isEmpty
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : phoneNumber[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    displayName.isNotEmpty ? displayName : phoneNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    phoneNumber,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          contactName:
                              displayName.isNotEmpty ? displayName : '',
                          phoneNumber: phoneNumber,
                        ),
                      ),
                    ).then((_) {
                      onChatStarted(
                          contact); // Add contact to recent chats after returning from chat page
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.contacts),
        onPressed: () async {
          if (await Permission.contacts.request().isGranted) {
            List<Contact> contacts = await ContactsService.getContacts();
            Navigator.push(
              // ignore: use_build_context_synchronously
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
                          phoneNumber:
                              contact.phones?.first.value ?? 'No Number',
                        ),
                      ),
                    ).then((_) {
                      onChatStarted(
                          contact); // Add contact to recent chats after returning from chat page
                    });
                  },
                ),
              ),
            );
          } else {
            // Handle permission denied case
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contacts permission denied')),
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                // Chat button functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                // Voice call button functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () {
                // Video call button functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Settings button functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
