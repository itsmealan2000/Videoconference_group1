import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:videoconference/ChatPage.dart';

class ContactsPage extends StatelessWidget {
  final List<Contact> contacts;

  const ContactsPage({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final List<Contact> validContacts = contacts.where((contact) {
      final String displayName = contact.displayName ?? '';
      final String phoneNumber = contact.phones?.isNotEmpty == true
          ? contact.phones!.first.value ?? ''
          : '';
      return displayName.isNotEmpty || phoneNumber.isNotEmpty;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: validContacts.isEmpty
          ? const Center(child: Text('No valid contacts found'))
          : ListView.separated(
              itemCount: validContacts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final contact = validContacts[index];
                final String displayName = contact.displayName ?? 'No Name';
                final String phoneNumber = contact.phones?.isNotEmpty == true
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
                    // Navigate to the chat page when a contact is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          contactName:
                              displayName.isNotEmpty ? displayName : '',
                          phoneNumber: phoneNumber,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
