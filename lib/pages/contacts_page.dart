import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactsPage extends StatelessWidget {
  final List<Contact> contacts;
  final Function(Contact) onContactSelected;

  const ContactsPage({
    super.key,
    required this.contacts,
    required this.onContactSelected,
  });

  Future<List<Map<String, dynamic>>> fetchContactsFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Error fetching contacts from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchContactsFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching contacts: ${snapshot.error}'));
            
          }

          final firestoreContacts = snapshot.data ?? [];
          final matchedContacts = contacts.where((localContact) {
            final phoneNumber = localContact.phones?.isNotEmpty == true ? localContact.phones!.first.value : null;
            final email = localContact.emails?.isNotEmpty == true ? localContact.emails!.first.value : null;

            return firestoreContacts.any((firestoreContact) {
              return (firestoreContact['mobileNumber'] == phoneNumber || firestoreContact['email'] == email);
            });
          }).toList();

          if (matchedContacts.isEmpty) {
            return const Center(child: Text('No matching contacts found'));
          }

          return ListView.builder(
            itemCount: matchedContacts.length,
            itemBuilder: (context, index) {
              final contact = matchedContacts[index];
              final displayName = contact.displayName ?? 'No Name';
              final phoneNumber = contact.phones?.isNotEmpty == true ? contact.phones!.first.value ?? 'No Number' : 'No Number';

              return ListTile(
                title: Text(displayName),
                subtitle: Text(phoneNumber),
                onTap: () => onContactSelected(contact),
              );
            },
          );
        },
      ),
    );
  }
}
