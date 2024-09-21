import 'package:flutter/material.dart';
import 'package:videoconference/pages/settings.dart';
import 'package:videoconference/pages/home_page.dart';

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
              Navigator.pushReplacement(
                context, 
                PageRouteBuilder(
                  pageBuilder: 
                    (context, animation, secondaryAnimation) => const HomePage(),
                  transitionDuration: Duration.zero,  // Disable transition duration
                  reverseTransitionDuration: Duration.zero,  // Disable reverse transition duration
                ),
              );
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
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const Settings(),
                  transitionDuration: Duration.zero,  // Disable transition duration
                  reverseTransitionDuration: Duration.zero,  // Disable reverse transition duration
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
