import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactsPage extends StatelessWidget {
  final List<Contact> contacts;
  final Function(Contact) onContactSelected;

  const ContactsPage({
    super.key,
    required this.contacts,
    required this.onContactSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final displayName = contact.displayName ?? 'No Name';
          final phoneNumber = contact.phones?.isNotEmpty == true
              ? contact.phones!.first.value ?? 'No Number'
              : 'No Number';

          // Skip contacts without name or number
          if (displayName == 'No Name' && phoneNumber == 'No Number') {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              ListTile(
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
                subtitle: Text(phoneNumber),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () {
                        // Trigger voice call functionality (implement accordingly)
                        if (kDebugMode) {
                          print('Voice call to $phoneNumber');
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.blue),
                      onPressed: () {
                        // Trigger video call functionality (implement accordingly)
                        if (kDebugMode) {
                          print('Video call to $phoneNumber');
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  onContactSelected(contact);
                },
              ),
              const Divider(), // Line between contacts
            ],
          );
        },
      ),
    );
  }
}
