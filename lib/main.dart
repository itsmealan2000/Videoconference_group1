import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/auth/auth_page.dart';
import 'package:videoconference/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Conference App',
      debugShowCheckedModeBanner: false,
      home:AuthPage()
    );
  }
}
