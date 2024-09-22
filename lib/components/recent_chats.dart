import 'package:flutter/material.dart';
import 'package:videoconference/components/chat_screen.dart';

class RecentChats extends StatelessWidget {
  final List<Map<String, String>> recentChats;

const RecentChats({super.key, required this.recentChats});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}
