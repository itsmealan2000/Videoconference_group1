import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactsPage extends StatelessWidget {
  final List<Contact> contacts;
  final Function(Contact) onContactSelected;
  final String currentUser;

  const ContactsPage({
    super.key,
    required this.contacts,
    required this.onContactSelected,
    required this.currentUser,
  });

  // Fetch contacts from Firestore
  Future<List<Map<String, dynamic>>> fetchContactsFromFirestore() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      // Convert documents to a List of Maps
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching contacts from Firestore: $e');
    }
  }

  // Normalize phone number to remove non-digit characters
  String normalizePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) return '';
    return phoneNumber.replaceAll(
        RegExp(r'\D'), ''); // Remove non-digit characters
  }

  // Generate unique chat ID based on current user and contact's phone number
  String generateChatId(String currentUser, String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return ''; // Handle empty phone numbers
    }
    return currentUser.compareTo(phoneNumber) > 0
        ? '$currentUser _$phoneNumber'
        : '$phoneNumber _$currentUser';
  }

  // Add recent chat details to Firestore
  Future<void> addRecentChatToFirestore(
      String contactName, String phoneNumber) async {
    try {
      final chatData = {
        'contactName': contactName,
        'phoneNumber': phoneNumber,
        'timestamp':
            FieldValue.serverTimestamp(), // Set timestamp to server time
      };

      await FirebaseFirestore.instance.collection('recentChats').add(chatData);
    } catch (e) {
      // Handle 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchContactsFromFirestore(), // Fetch contacts from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching contacts: ${snapshot.error}'));
          }
          final firestoreContacts = snapshot.data ?? [];
          final matchedContacts = contacts.where((localContact) {
            final phoneNumber = localContact.phones?.isNotEmpty == true
                ? normalizePhoneNumber(localContact.phones!.first.value)
                : null;
            final email = localContact.emails?.isNotEmpty == true
                ? localContact.emails!.first.value
                : null;
            final fullName = localContact.displayName;

            // Exclude current user's contact details
            if (fullName == currentUser ||
                phoneNumber == normalizePhoneNumber(currentUser)) {
              return false; // Skip current user details
            }

            // Match against Firestore contacts
            return firestoreContacts.any((firestoreContact) {
              final firestorePhoneNumber =
                  normalizePhoneNumber(firestoreContact['mobileNumber']);
              final firestoreFullName = firestoreContact['fullName'];

              return (firestorePhoneNumber == phoneNumber ||
                  firestoreContact['email'] == email ||
                  firestoreFullName == fullName);
            });
          }).toList();

          if (matchedContacts.isEmpty) {
            return const Center(child: Text('No matching contacts found'));
          }

          return ListView.builder(
            itemCount: matchedContacts.length,
            itemBuilder: (context, index) {
              final localContact = matchedContacts[index];
              final phoneNumber = localContact.phones?.isNotEmpty == true
                  ? normalizePhoneNumber(localContact.phones!.first.value)
                  : null;

              final firestoreContact = firestoreContacts.firstWhere(
                (firestoreContact) {
                  final firestorePhoneNumber =
                      normalizePhoneNumber(firestoreContact['mobileNumber']);
                  return firestorePhoneNumber == phoneNumber;
                },
                orElse: () => {
                  'fullName': 'No Name',
                  'mobileNumber': ''
                }, // Default values
              );

              final displayName = firestoreContact['fullName'];
              final firestorePhoneNumber = firestoreContact['mobileNumber'];

              // Exclude current user by checking if the displayName matches currentUser
              if (displayName != null &&
                  displayName.trim().toLowerCase() ==
                      currentUser.trim().toLowerCase()) {
                return const SizedBox
                    .shrink(); 
              }

              // Only show contacts with a valid phone number
              if (firestorePhoneNumber.isEmpty) return const SizedBox.shrink();

              return ListTile(
                title: Text(displayName),
                subtitle: Text(firestorePhoneNumber),
                onTap: () async {
                  await addRecentChatToFirestore(
                      displayName, firestorePhoneNumber);

                },
              );
            },
          );
        },
      ),
    );
  }
}
