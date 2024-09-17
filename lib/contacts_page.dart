import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactsPage extends StatelessWidget {
  final List<Contact> contacts;

  const ContactsPage({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    // Filter contacts to remove those with no name and no phone number
    final List<Contact> validContacts = contacts.where((contact) {
      final String displayName = contact.displayName ?? '';
      final String phoneNumber = contact.phones?.isNotEmpty == true
          ? contact.phones!.first.value ?? ''
          : '';
      return displayName.isNotEmpty ||
          phoneNumber
              .isNotEmpty; // Keep only contacts with name or phone number
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: validContacts.isEmpty
          ? const Center(child: Text('No valid contacts found'))
          : ListView.separated(
              itemCount: validContacts.length,
              separatorBuilder: (context, index) =>
                  const Divider(), // Add line between each contact
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
                            ? MemoryImage(
                                contact.avatar!) // Display contact's avatar
                            : null, // If no avatar, display a placeholder
                    child: contact.avatar == null || contact.avatar!.isEmpty
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0]
                                    .toUpperCase() // First letter of the name
                                : phoneNumber[
                                    0], // First digit of the phone number
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    displayName.isNotEmpty
                        ? displayName
                        : phoneNumber, // Display name or phone number
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    phoneNumber, // Display phone number as subtitle
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
