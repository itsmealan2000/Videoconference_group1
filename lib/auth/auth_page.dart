import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/auth/login_page.dart';
import 'package:videoconference/pages/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.contacts,
      Permission.phone,
      Permission.camera,
      Permission.microphone,
    ].request();

    setState(() {
      _permissionsGranted = statuses.values.every((status) => status.isGranted);
    });
    if (!mounted) return; 
    if (!_permissionsGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permissions are required to proceed.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!_permissionsGranted) {
            return const Center(child: CircularProgressIndicator());
          }

          return snapshot.hasData ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}
