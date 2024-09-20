import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
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
    );
  }
}
