import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'VoiceCallPage.dart';
import 'VideoCallPage.dart';

class ContactsPage extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Contact) onContactSelected;

  const ContactsPage({
    super.key,
    required this.contacts,
    required this.onContactSelected,
  });

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> filteredContacts = [];
  bool _isSearching = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    filteredContacts = widget.contacts;
  }

  void _searchContacts(String query) {
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        filteredContacts = widget.contacts;
      } else {
        filteredContacts = widget.contacts.where((contact) {
          final displayName = contact.displayName?.toLowerCase() ?? '';
          final phoneNumber = contact.phones?.isNotEmpty == true
              ? contact.phones!.first.value?.toLowerCase() ?? ''
              : '';

          return displayName.contains(query.toLowerCase()) ||
              phoneNumber.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchText = '';
              filteredContacts = widget.contacts;
            });
          },
        ),
        title: TextField(
          onChanged: _searchContacts,
          decoration: const InputDecoration(
            hintText: 'Search contacts...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
      );
    } else {
      return AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = filteredContacts[index];
          final displayName = contact.displayName ?? 'No Name';
          final phoneNumber = contact.phones?.isNotEmpty == true
              ? contact.phones!.first.value ?? 'No Number'
              : 'No Number';

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
                        // Navigate to voice call page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VoiceCallPage(phoneNumber: phoneNumber, contactName: '',),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.blue),
                      onPressed: () {
                        // Navigate to video call page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoCallPage(phoneNumber: phoneNumber, contactName: '',),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  widget.onContactSelected(contact);
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
