import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String contactName;
  final String phoneNumber;

const ChatPage({super.key, required this.contactName, required this.phoneNumber});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contactName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('Chat with $contactName'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // Handle sending message logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
