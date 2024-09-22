
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:videoconference/components/bottomnavbar.dart'; // Import BottomNavBar
import 'package:videoconference/auth/login_page.dart'; // Import LoginPage
import 'package:fluttertoast/fluttertoast.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  User? user;
  String fullName = '';

  @override
  void initState() {
    super.initState();
    // Fetch the current user
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch the full name from Firestore
      _fetchFullName(user!.email!);
    }
  }

  Future<void> _fetchFullName(String email) async {
    try {
      // Query Firestore for the user's full name
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          fullName = snapshot['fullName'] ?? ''; // Get full name
        });
      }
    }
    catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching full name: $e');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const LoginPage()), // Navigate to login page
      (route) => false, // Remove all previous routes
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _logout(); // Perform logout
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                  'Welcome ${fullName.isNotEmpty ? fullName : user!.email}'),
              subtitle: Text('Logged in as ${user!.email}'),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
