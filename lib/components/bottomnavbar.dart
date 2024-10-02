import 'package:flutter/material.dart';
import 'package:videoconference/pages/settings.dart';
import 'package:videoconference/pages/home_page.dart';
import 'package:videoconference/pages/history.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                PageRouteBuilder(
                  pageBuilder: 
                    (context, animation, secondaryAnimation) => const HomePage(),
                  transitionDuration: Duration.zero,  
                  reverseTransitionDuration: Duration.zero,  
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: 
                    (context, animation, secondaryAnimation) => const HistoryPage(),
                  transitionDuration: Duration.zero,  
                  reverseTransitionDuration: Duration.zero,  
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const Settings(),
                  transitionDuration: Duration.zero,  
                  reverseTransitionDuration: Duration.zero,  
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
